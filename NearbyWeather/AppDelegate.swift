//
//  AppDelegate.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.12.16.
//  Copyright © 2016 Erik Maximilian Martens. All rights reserved.
//

import UIKit

protocol WindowManager: class {
  var window: UIWindow? { get set }
  var splashScreenWindow: UIWindow? { get set }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WindowManager {
  
  private var mainCoordinator: MainCoordinator?
  private var welcomeCoordinator: WelcomeCoordinator?
  
  var window: UIWindow?
  var splashScreenWindow: UIWindow?
  
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
    mainCoordinator = MainCoordinator(parentCoordinator: nil, windowManager: self)
    
    NotificationCenter.default.post(
      name: Notification.Name(rawValue: MainStep.identifier),
      object: self,
      userInfo: [Constants.Keys.AppCoordinator.kStep: MainStep.initial]
    )
    
    if UserDefaults.standard.value(forKey: Constants.Keys.UserDefaults.kNearbyWeatherApiKeyKey) == nil {
      welcomeCoordinator = WelcomeCoordinator(parentCoordinator: nil, windowManager: self)
      
      NotificationCenter.default.post(
        name: Notification.Name(rawValue: WelcomeStep.identifier),
        object: self,
        userInfo: [Constants.Keys.AppCoordinator.kStep: WelcomeStep.initial]
      )
    }
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
