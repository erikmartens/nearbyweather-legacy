//
//  AppDelegate.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.12.16.
//  Copyright © 2016 Erik Maximilian Martens. All rights reserved.
//

import UIKit

protocol MainWindowManager: class {
  var window: UIWindow? { get set }
}

protocol WelcomeWindowManager: class {
  var welcomeWindow: UIWindow? { get set }
  func notifyForMainAppLaunch()
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MainWindowManager, WelcomeWindowManager {
  
  private var mainCoordinator: MainCoordinator?
  private var welcomeCoordinator: WelcomeCoordinator?
  
  var window: UIWindow?
  var welcomeWindow: UIWindow?
  
  private var backgroundTaskId: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    instantiateServices()
    instantiateApplicationUserInterface()
    
    return true
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    refreshWeatherDataIfNeeded()
  }
  
  func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    self.backgroundTaskId = application.beginBackgroundTask { [weak self] in
      self?.endBackgroundTask()
    }
    
    WeatherDataManager.shared.updatePreferredBookmark { [weak self] result in
      switch result {
      case .success:
        completionHandler(.newData)
      case .failure:
        completionHandler(.failed)
      }
      self?.endBackgroundTask()
    }
  }
  
  func notifyForMainAppLaunch() {
    mainCoordinator = MainCoordinator(parentCoordinator: nil, windowManager: self)
    (mainCoordinator?.stepper as? MainStepper)?.requestRouting(toStep: .initial)
    window?.makeKeyAndVisible()
  }
}

// MARK: - Private Helper Functions

extension AppDelegate {
  
  private func instantiateServices() {
    WeatherNetworkingService.instantiateSharedInstance()
    UserLocationService.instantiateSharedInstance()
    PreferencesManager.instantiateSharedInstance()
    WeatherStationService.instantiateSharedInstance()
    WeatherDataManager.instantiateSharedInstance()
    PermissionsService.instantiateSharedInstance()
    BadgeService.instantiateSharedInstance()
  }
  
  private func instantiateApplicationUserInterface() {
    guard UserDefaults.standard.value(forKey: Constants.Keys.UserDefaults.kNearbyWeatherApiKeyKey) != nil else {
      welcomeCoordinator = WelcomeCoordinator(parentCoordinator: nil, windowManager: self)
      (welcomeCoordinator?.stepper as? WelcomeStepper)?.requestRouting(toStep: .initial)
      return
    }
    mainCoordinator = MainCoordinator(parentCoordinator: nil, windowManager: self)
    (mainCoordinator?.stepper as? MainStepper)?.requestRouting(toStep: .initial)
  }
  
  private func refreshWeatherDataIfNeeded() {
    if UserDefaults.standard.value(forKey: Constants.Keys.UserDefaults.kNearbyWeatherApiKeyKey) != nil,
      UserDefaults.standard.bool(forKey: Constants.Keys.UserDefaults.kRefreshOnAppStartKey) == true {
      WeatherDataManager.shared.update(withCompletionHandler: nil)
    }
  }
  
  private func endBackgroundTask() {
    UIApplication.shared.endBackgroundTask(backgroundTaskId)
    backgroundTaskId = .invalid
  }
}
