//
//  AppDelegate.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.12.16.
//  Copyright © 2016 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxSwift
import RxOptional
import RxFlow
import Swinject
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  // MARK: - Properties
  
  var window: UIWindow?
  var welcomeWindow: UIWindow?
  
  private var dependencyContainer: Container!
  private var flowCoordinator: FlowCoordinator!
  
  private var daemons: [Daemon] = []
  
  private var backgroundFetchTaskId: UIBackgroundTaskIdentifier = .invalid
  
  // MARK: - Functions
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // TODO: Handle via NSOperations
    registerServices()
    runMigrationIfNeeded()
    
    instantiateApplicationUserInterface()
    
    // TODO: create secrets sub-repo and git-ignore
    if let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
       let firebaseOptions = FirebaseOptions(contentsOfFile: filePath) {
      FirebaseApp.configure(options: firebaseOptions)
    }
    
    SettingsBundleTransferWorker.updateSystemSettings()
    
    return true
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    instantiateDaemons()
    refreshWeatherDataIfNeeded()
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    daemons.forEach { $0.stopObservations() }
    daemons = []
  }
  
  func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    beginAppIconUpdateBackgroundFetchTask(for: application, performFetchWithCompletionHandler: completionHandler)
  }
  
  func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
    daemons.forEach { $0.stopObservations() }
    daemons = []
    instantiateDaemons()
  }
}

// MARK: - Private Helper Functions

private extension AppDelegate {
  
  func registerServices() {
    dependencyContainer = Container()
    
    dependencyContainer.register(PersistencyService.self) { _ in PersistencyService() }
    dependencyContainer.register(UserLocationService.self) { resolver in
      UserLocationService(
        dependencies: UserLocationService.Dependencies(persistencyService: resolver.resolve(PersistencyService.self)!
                                                       ))
    }
    
    dependencyContainer.register(PreferencesService.self) { resolver in
      PreferencesService(dependencies: PreferencesService.Dependencies(
        persistencyService: resolver.resolve(PersistencyService.self)!
      ))
    }
    
    dependencyContainer.register(ApiKeyService.self) { resolver in
      ApiKeyService(dependencies: ApiKeyService.Dependencies(
        persistencyService: resolver.resolve(PersistencyService.self)!
      ))
    }
    
    dependencyContainer.register(WeatherStationService.self) { resolver in
      WeatherStationService(dependencies: WeatherStationService.Dependencies(
        persistencyService: resolver.resolve(PersistencyService.self)!
      ))
    }
    
    dependencyContainer.register(WeatherInformationService.self) { resolver in
      WeatherInformationService(dependencies: WeatherInformationService.Dependencies(
        persistencyService: resolver.resolve(PersistencyService.self)!,
        preferencesService: resolver.resolve(PreferencesService.self)!,
        weatherStationService: resolver.resolve(WeatherStationService.self)!,
        userLocationService: resolver.resolve(UserLocationService.self)!,
        apiKeyService: resolver.resolve(ApiKeyService.self)!
      ))
    }
    
    dependencyContainer.register(NetworkReachabilityService.self) { _ in
      NetworkReachabilityService()
    }
    
    dependencyContainer.register(NotificationService.self) { resolver in
      NotificationService(dependencies: NotificationService.Dependencies(
        persistencyService: resolver.resolve(PersistencyService.self)!,
        weatherStationService: resolver.resolve(WeatherStationService.self)!,
        weatherInformationService: resolver.resolve(WeatherInformationService.self)!,
        preferencesService: resolver.resolve(PreferencesService.self)!
      ))
    }
  }
  
  func instantiateDaemons() {
    let apiKeyService = dependencyContainer.resolve(ApiKeyService.self)!
    let preferencesService = dependencyContainer.resolve(PreferencesService.self)!
    let userLocationService = dependencyContainer.resolve(UserLocationService.self)!
    let weatherStationService = dependencyContainer.resolve(WeatherStationService.self)!
    let weatherInformationService = dependencyContainer.resolve(WeatherInformationService.self)!
    let notificationService = dependencyContainer.resolve(NotificationService.self)!
    
    daemons.append(contentsOf: [
      WeatherInformationUpdateDaemon(dependencies: WeatherInformationUpdateDaemon.Dependencies(
        apiKeyService: apiKeyService,
        preferencesService: preferencesService,
        userLocationService: userLocationService,
        weatherStationService: weatherStationService,
        weatherInformationService: weatherInformationService
      )),
      UserLocationUpdateDaemon(dependencies: UserLocationUpdateDaemon.Dependencies(
        userLocationService: userLocationService
      )),
      NotificationUpdateDaemon(dependencies: NotificationUpdateDaemon.Dependencies(
        weatherStationService: weatherStationService,
        weatherInformationService: weatherInformationService,
        preferencesService: preferencesService,
        notificationService: notificationService
      ))
    ])
    
    daemons.forEach { $0.startObservations() }
  }
  
  func instantiateApplicationUserInterface() {
    let window = UIWindow(frame: UIScreen.main.bounds)
    self.window = window
    let rootFlow = RootFlow(dependencies: RootFlow.Dependencies(
      rootWindow: window,
      dependencyContainer: dependencyContainer!
    ))
    
    flowCoordinator = FlowCoordinator()
    flowCoordinator?.coordinate(
      flow: rootFlow,
      with: RootStepper(
        dependencies: RootStepper.Dependencies(apiKeyService: dependencyContainer.resolve(ApiKeyService.self)!)
      )
    )
  }
  
  func refreshWeatherDataIfNeeded() {
    let preferencesService = dependencyContainer.resolve(PreferencesService.self)! as AppDelegatePreferenceReading
    let weatherInformationService = dependencyContainer.resolve(WeatherInformationService.self)! as WeatherInformationUpdating
    
    _ = preferencesService
      .createGetRefreshOnAppStartOptionObservable()
      .take(1)
      .asSingle()
      .flatMapCompletable { [weatherInformationService] refreshOnAppStartOption -> Completable in
        guard refreshOnAppStartOption.value == .yes else {
          return Completable.create { handler in
            handler(.completed)
            return Disposables.create()
          }
        }
        return Completable.zip([
          weatherInformationService.createUpdateBookmarkedWeatherInformationCompletable(),
          weatherInformationService.createUpdateNearbyWeatherInformationCompletable()
        ])
      }
      .subscribe()
  }
  
  func beginAppIconUpdateBackgroundFetchTask(for application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    let taskName = "de.erikmaximilianmartens.nearbyweather.bookmarked_weather_information_background_fetch" // Move to constants
    backgroundFetchTaskId = application.beginBackgroundTask(withName: taskName, expirationHandler: { [weak self] in
      self?.endAppIconUpdateBackgroundFetchTask()
    })
    
    let preferencesService = dependencyContainer.resolve(PreferencesService.self)!
    let weatherStationService = dependencyContainer.resolve(WeatherStationService.self)!
    let weatherInformationService = dependencyContainer.resolve(WeatherInformationService.self)!
    let notificationService = dependencyContainer.resolve(NotificationService.self)!
    
    _ = weatherStationService
      .createGetPreferredBookmarkObservable()
      .flatMapLatest { preferredBookmarkOption -> Observable<TemperatureOnAppIconBadgeInformation?> in
        guard let stationIdentifierInt = preferredBookmarkOption?.intValue else {
          return Observable.just(nil)
        }
        return Observable
          .combineLatest(
            weatherInformationService.createGetBookmarkedWeatherInformationItemObservable(for: String(stationIdentifierInt)).map { $0.entity },
            preferencesService.createGetTemperatureUnitOptionObservable(),
            resultSelector: TemperatureOnAppIconBadgeInformation.init)
      }
      .take(1)
      .asSingle()
      .flatMapCompletable { temperatureOnAppIconBadgeInformation in
        guard let temperatureOnAppIconBadgeInformation = temperatureOnAppIconBadgeInformation else {
          DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = 0
          }
          return Completable.create { handler in
            handler(.completed)
            return Disposables.create()
          }
        }
        return notificationService.createPerformTemperatureOnBadgeUpdateCompletable(with: temperatureOnAppIconBadgeInformation)
      }
      .subscribe(
        onCompleted: { [weak self] in
          completionHandler(.newData)
          self?.endAppIconUpdateBackgroundFetchTask()
        },
        onError: { [weak self] _ in
          completionHandler(.failed)
          self?.endAppIconUpdateBackgroundFetchTask()
        }
      )
  }
  
  func endAppIconUpdateBackgroundFetchTask() {
    UIApplication.shared.endBackgroundTask(backgroundFetchTaskId)
    backgroundFetchTaskId = .invalid
  }
  
  func runMigrationIfNeeded() {
    MigrationService(dependencies: MigrationService.Dependencies(
      preferencesService: dependencyContainer.resolve(PreferencesService.self)!,
      weatherInformationService: dependencyContainer.resolve(WeatherInformationService.self)!,
      weatherStationService: dependencyContainer.resolve(WeatherStationService.self)!,
      apiKeyService: dependencyContainer.resolve(ApiKeyService.self)!,
      notificationService: dependencyContainer.resolve(NotificationService.self)!
    ))
      .runMigrationIfNeeded_v2_2_2_to_3_0_0()
  }
}
