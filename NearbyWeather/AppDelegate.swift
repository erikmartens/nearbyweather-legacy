//
//  AppDelegate.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.12.16.
//  Copyright © 2016 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxSwift
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

  private var backgroundFetchTaskId: UIBackgroundTaskIdentifier = .invalid

  // MARK: - Functions

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//    FirebaseApp.configure()

    instantiateServices()
    instantiateApplicationUserInterface()

    runMigrationIfNeeded()

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
    beginBackgroundFetchTask(for: application, performFetchWithCompletionHandler: completionHandler)
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

  func instantiateApplicationUserInterface() {
    let window = UIWindow(frame: UIScreen.main.bounds)
    self.window = window
    let rootFlow = RootFlow(
      rootWindow: window,
      dependencyContainer: dependencyContainer!
    )

    flowCoordinator = FlowCoordinator()
    flowCoordinator?.coordinate(
      flow: rootFlow,
      with: RootStepper()
    )
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
  
  func beginBackgroundFetchTask(for application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    let taskName = "de.erikmaximilianmartens.nearbyweather.bookmarked_weather_information_background_fetch"
    backgroundFetchTaskId = application.beginBackgroundTask(withName: taskName, expirationHandler: { [weak self] in
      self?.endBackgroundFetchTask()
    })
    
    _ = dependencyContainer
      .resolve(WeatherInformationService2.self)!
      .createUpdateBookmarkedWeatherInformationCompletable()
      .subscribe(
        onCompleted: { [weak self] in
          completionHandler(.newData)
          self?.endBackgroundFetchTask()
        },
        onError: { [weak self] _ in
          completionHandler(.failed)
          self?.endBackgroundFetchTask()
        }
      )
  }

  func endBackgroundFetchTask() {
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
    .runMigrationIfNeeded()
  }
}
