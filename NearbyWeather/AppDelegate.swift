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
  private var daemonContainer: Container!
  private var flowCoordinator: FlowCoordinator!

  private var backgroundFetchTaskId: UIBackgroundTaskIdentifier = .invalid

  // MARK: - Functions

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//    FirebaseApp.configure()

    instantiateServices()
    instantiateDaemons()
    instantiateApplicationUserInterface()

    runMigrationIfNeeded()

    // TODO: create secrets sub-repo and git-ignore
    if let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
      let firebaseOptions = FirebaseOptions(contentsOfFile: filePath) {
      FirebaseApp.configure(options: firebaseOptions)
    }

    SettingsBundleTransferWorker.updateSystemSettings()

    return true
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    refreshWeatherDataIfNeeded()
  }

  func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    beginAppIconUpdateBackgroundFetchTask(for: application, performFetchWithCompletionHandler: completionHandler)
  }
  
  func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
    daemonContainer = nil
    instantiateDaemons()
  }
}

// MARK: - Private Helper Functions

private extension AppDelegate {

  func instantiateServices() {
    PermissionsService.instantiateSharedInstance()
    BadgeService.instantiateSharedInstance()

    dependencyContainer = Container()

    dependencyContainer.register(PersistencyService2.self) { _ in PersistencyService2() }
    dependencyContainer.register(UserLocationService2.self) { _ in UserLocationService2() }
    
    dependencyContainer.register(PreferencesService2.self) { resolver in
      PreferencesService2(dependencies: PreferencesService2.Dependencies(
        persistencyService: resolver.resolve(PersistencyService2.self)!
      ))
    }
    
    dependencyContainer.register(ApiKeyService2.self) { resolver in
      ApiKeyService2(dependencies: ApiKeyService2.Dependencies(
        persistencyService: resolver.resolve(PersistencyService2.self)!
      ))
    }
    
    dependencyContainer.register(WeatherStationService2.self) { resolver in
      WeatherStationService2(dependencies: WeatherStationService2.Dependencies(
        persistencyService: resolver.resolve(PersistencyService2.self)!
      ))
    }
    
    dependencyContainer.register(WeatherInformationService2.self) { resolver in
      WeatherInformationService2(dependencies: WeatherInformationService2.Dependencies(
        persistencyService: resolver.resolve(PersistencyService2.self)!,
        preferencesService: resolver.resolve(PreferencesService2.self)!,
        weatherStationService: resolver.resolve(WeatherStationService2.self)!,
        userLocationService: resolver.resolve(UserLocationService2.self)!,
        apiKeyService: resolver.resolve(ApiKeyService2.self)!
      ))
    }
  }
  
  func instantiateDaemons() {
    daemonContainer = Container()
    
    let apiKeyService = dependencyContainer.resolve(ApiKeyService2.self)!
    let userLocationService = dependencyContainer.resolve(UserLocationService2.self)!
    let weatherStationService = dependencyContainer.resolve(WeatherStationService2.self)!
    let weatherInformationService = dependencyContainer.resolve(WeatherInformationService2.self)!
    
    daemonContainer.register(WeatherInformationUpdateDaemon.self) { [weak apiKeyService, weak userLocationService, weak weatherStationService, weak weatherInformationService] _ in
      WeatherInformationUpdateDaemon(dependencies: WeatherInformationUpdateDaemon.Dependencies(
        apiKeyService: apiKeyService,
        userLocationService: userLocationService,
        weatherStationService: weatherStationService,
        weatherInformationService: weatherInformationService
      ))
    }
  }

  func instantiateApplicationUserInterface() {
    let window = UIWindow(frame: UIScreen.main.bounds)
    self.window = window
    let rootFlow = RootFlow(dependencies: RootFlow.Dependencies(
      rootWindow: window,
      dependencyContainer: dependencyContainer!
    ))

    flowCoordinator = FlowCoordinator()
    flowCoordinator?.coordinate(flow: rootFlow, with: RootStepper())
  }

  func refreshWeatherDataIfNeeded() {
    let preferencesService = dependencyContainer.resolve(PreferencesService2.self)! as AppDelegatePreferenceReading
    let weatherInformationService = dependencyContainer.resolve(WeatherInformationService2.self)! as WeatherInformationUpdating
    
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
    
    _ = dependencyContainer
      .resolve(WeatherStationService2.self)!
      .createGetPreferredBookmarkObservable()
      .map { $0?.value }
      .errorOnNil()
      .take(1)
      .asSingle()
      .flatMapCompletable { [unowned dependencyContainer] preferredBookmark -> Completable in
        dependencyContainer!
          .resolve(WeatherInformationService2.self)!
          .createUpdateBookmarkedWeatherInformationCompletable(forStationWith: preferredBookmark)
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
      preferencesService: dependencyContainer.resolve(PreferencesService2.self)!,
      weatherInformationService: dependencyContainer.resolve(WeatherInformationService2.self)!,
      weatherStationService: dependencyContainer.resolve(WeatherStationService2.self)!,
      apiKeyService: dependencyContainer.resolve(ApiKeyService2.self)!
    ))
    .runMigrationIfNeeded_v2_2_2_to_3_0_0()
  }
}
