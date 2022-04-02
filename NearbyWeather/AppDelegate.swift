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
  
  private var flowCoordinator: FlowCoordinator!
  
  private var dependencyContainer: Container!
  private var daemonContainer: [Daemon] = []
  
  private let daemonsAreRunningSubject = BehaviorSubject<Bool>(value: false)
  private let migrationIsRunningSubject = BehaviorSubject<Bool>(value: false)
  
  private var tempOnAsAppIconBadgeBackgroundFetchTaskId: UIBackgroundTaskIdentifier = .invalid
  
  // MARK: - Functions
  
  /// only called on cold start
  func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    registerServices()
    instantiateDaemons()
    instantiateFirebase()
    
    setInstallVersionIfNeeded()
    runMigrationIfNeeded()
    
    SettingsBundleTransferWorker.updateSystemSettings()
    
    return true
  }
  
  /// only called on cold start
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    instantiateApplicationUserInterface()
    startDaemons()
    return true
  }
  
  /// only called on warm start but not when app was unactive from control centre etc. being invoked
  func applicationWillEnterForeground(_ application: UIApplication) {
    startDaemons()
  }
  
  /// called on any start
  func applicationDidBecomeActive(_ application: UIApplication) {
    startDaemons()
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    stopDaemons()
  }
  
  func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    beginTempAsAppIconBadgeBackgroundFetchTask(for: application, performFetchWithCompletionHandler: completionHandler)
  }
  
  func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
    restartDaemons()
  }
}

// MARK: - Private Helper Functions

private extension AppDelegate {
  
  func registerServices() {
    dependencyContainer = Container()
    
    dependencyContainer.register(PersistencyService.self) { _ in PersistencyService() }
    
    dependencyContainer.register(ApplicationCycleService.self) { resolver in
      ApplicationCycleService(
        dependencies: ApplicationCycleService.Dependencies(persistencyService: resolver.resolve(PersistencyService.self)!
                                                      ))
    }
    
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
    
    daemonContainer.append(contentsOf: [
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
  }
  
  func startDaemons() {
    _ = daemonsAreRunningSubject
      .asObservable()
      .take(1)
      .asSingle()
      .flatMapCompletable { [unowned self] running in
        if !running {
          daemonContainer.forEach { $0.startObservations() }
          daemonsAreRunningSubject.onNext(true)
          printDebugMessage(
            domain: String(describing: self),
            message: "👹 STARTED",
            type: .info
          )
        }
        return Completable.emptyCompletable
      }
        .subscribe()
    
  }
  
  func stopDaemons() {
    printDebugMessage(
      domain: String(describing: self),
      message: "👹 STOPPED",
      type: .info
    )
    
    daemonContainer.forEach { $0.stopObservations() }
    daemonsAreRunningSubject.onNext(false)
  }
  
  func restartDaemons() {
    stopDaemons()
    daemonContainer = []
    instantiateDaemons()
    startDaemons()
  }
  
  func instantiateFirebase() {
    if let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
       let firebaseOptions = FirebaseOptions(contentsOfFile: filePath) {
      FirebaseApp.configure(options: firebaseOptions)
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
    flowCoordinator?.coordinate(
      flow: rootFlow,
      with: RootStepper(dependencies: RootStepper.Dependencies(
        applicationCycleService: dependencyContainer.resolve(ApplicationCycleService.self)!,
        migrationRunningObservable: migrationIsRunningSubject.asObservable()
      ))
    )
  }
  
  // TODO: move this to a background task worker
  func beginTempAsAppIconBadgeBackgroundFetchTask(for application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    tempOnAsAppIconBadgeBackgroundFetchTaskId = application.beginBackgroundTask(
      withName: Constants.Keys.BackgroundTaskIdentifiers.kRefreshTempOnAppIconBadge,
      expirationHandler: { [unowned self] in
        endTempAsAppIconBadgeBackgroundFetchTask()
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
            resultSelector: TemperatureOnAppIconBadgeInformation.init
          )
          .catchAndReturn(nil)
      }
      .take(1)
      .asSingle()
      .flatMapCompletable(notificationService.createPerformTemperatureOnBadgeUpdateCompletable)
      .subscribe(
        onCompleted: { [unowned self] in
          completionHandler(.newData)
          endTempAsAppIconBadgeBackgroundFetchTask()
        },
        onError: { [unowned self] _ in
          completionHandler(.failed)
          endTempAsAppIconBadgeBackgroundFetchTask()
        }
      )
  }
  
  func endTempAsAppIconBadgeBackgroundFetchTask() {
    UIApplication.shared.endBackgroundTask(tempOnAsAppIconBadgeBackgroundFetchTaskId)
    tempOnAsAppIconBadgeBackgroundFetchTaskId = .invalid
  }
  
  func setInstallVersionIfNeeded() {
    let applicationCycleService = dependencyContainer.resolve(ApplicationCycleService.self)!
    
    _ = applicationCycleService
      .createGetInstallVersionObservable()
      .take(1)
      .asSingle()
      .flatMapCompletable { installVersion in
        guard installVersion == nil else {
          return Completable.emptyCompletable
        }
        // TODO: log failure of writing installversion
        guard let installVersion = appVersion?.toInstallVersion else {
          return Completable.emptyCompletable
        }
        return applicationCycleService.createSetInstallVersionCompletable(installVersion)
      }
      .subscribe()
  }
  
  func runMigrationIfNeeded() {
    _ = MigrationService(dependencies: MigrationService.Dependencies(
      migrationIsRunningSubject: migrationIsRunningSubject,
      preferencesService: dependencyContainer.resolve(PreferencesService.self)!,
      weatherInformationService: dependencyContainer.resolve(WeatherInformationService.self)!,
      weatherStationService: dependencyContainer.resolve(WeatherStationService.self)!,
      apiKeyService: dependencyContainer.resolve(ApiKeyService.self)!,
      notificationService: dependencyContainer.resolve(NotificationService.self)!,
      applicationCycleService: dependencyContainer.resolve(ApplicationCycleService.self)!
    ))
    .createRun_2_2_1_to_3_0_0_migrationCompletable()
    .subscribe()
  }
}
