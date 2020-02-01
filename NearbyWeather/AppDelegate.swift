//
//  AppDelegate.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.12.16.
//  Copyright © 2016 Erik Maximilian Martens. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  var splashScreenWindow: UIWindow?
  
  private var backgroundTaskId: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    instantiateServices()
    
    /* UITabBar Appearance */
    
    UITabBar.appearance().backgroundColor = .white
    UITabBar.appearance().barTintColor = .white
    UITabBar.appearance().tintColor = .nearbyWeatherStandard
    
    let tabbar = self.window?.rootViewController as? UITabBarController
    
    /* Weather List Controller */
    let weatherListViewController = R.storyboard.list.weatherListViewController()!
    let weatherListNavigationController = UINavigationController(rootViewController: weatherListViewController)
    weatherListViewController.title = R.string.localizable.tab_weatherList().uppercased()
    weatherListViewController.tabBarItem.selectedImage = R.image.tabbar_list_ios11()
    weatherListViewController.tabBarItem.image = R.image.tabbar_list_ios11()
    
    /* Map Controller */
    let mapViewController = R.storyboard.map.nearbyLocationsMapViewController()!
    let mapNavigationController = UINavigationController(rootViewController: mapViewController)
    mapViewController.title = R.string.localizable.tab_weatherMap().uppercased()
    mapViewController.tabBarItem.selectedImage = R.image.tabbar_map_ios11()
    mapViewController.tabBarItem.image = R.image.tabbar_map_ios11()
    
    /* Settings Controller */
    let settingsViewController = SettingsTableViewController(style: .grouped)
    let settingsNavigationController = UINavigationController(rootViewController: settingsViewController)
    settingsViewController.title = R.string.localizable.tab_settings().uppercased()
    settingsViewController.tabBarItem.selectedImage = R.image.tabbar_settings_ios11()
    settingsViewController.tabBarItem.image = R.image.tabbar_settings_ios11()
    
    tabbar?.viewControllers = [weatherListNavigationController, mapNavigationController, settingsNavigationController]
    
    if UserDefaults.standard.value(forKey: Constants.Keys.UserDefaults.kNearbyWeatherApiKeyKey) == nil {
      showSplashScreenIfNeeded()
    } else {
      LocationService.shared.requestWhenInUseAuthorization()
    }
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
  
  // MARK: - Private Helpers
  
  private func refreshWeatherDataIfNeeded() {
    if UserDefaults.standard.value(forKey: Constants.Keys.UserDefaults.kNearbyWeatherApiKeyKey) != nil,
      UserDefaults.standard.bool(forKey: Constants.Keys.UserDefaults.kRefreshOnAppStartKey) == true {
      WeatherDataManager.shared.update(withCompletionHandler: nil)
    }
  }
  
  private func showSplashScreenIfNeeded() {
    let splashScreenWindow = UIWindow(frame: window!.bounds)
    let welcomeNav = R.storyboard.welcome().instantiateInitialViewController() as? WelcomeNavigationController
    welcomeNav?.welcomeNavigationDelegate = self
    splashScreenWindow.windowLevel = UIWindow.Level.alert
    
    splashScreenWindow.rootViewController = welcomeNav
    self.splashScreenWindow = splashScreenWindow
    self.splashScreenWindow?.makeKeyAndVisible()
  }
  
  private func endBackgroundTask() {
    UIApplication.shared.endBackgroundTask(self.backgroundTaskId)
    self.backgroundTaskId = UIBackgroundTaskIdentifier.invalid
  }
}

// MARK: - Private Helper Functions

extension AppDelegate {
  
  private func instantiateServices() {
    NetworkingService.instantiateSharedInstance()
    LocationService.instantiateSharedInstance()
    PreferencesManager.instantiateSharedInstance()
    WeatherLocationService.instantiateSharedInstance()
    WeatherDataManager.instantiateSharedInstance()
    PermissionsManager.instantiateSharedInstance()
    BadgeService.instantiateSharedInstance()
  }
}

extension AppDelegate: WelcomeNavigationDelegate {
  
  func dismissSplashScreen() {
    UIView.animate(withDuration: 0.2, animations: {
      self.splashScreenWindow?.alpha = 0
      self.splashScreenWindow?.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
    }, completion: { _ in
      self.splashScreenWindow?.resignKey()
      self.splashScreenWindow = nil
      self.window?.makeKeyAndVisible()
    })
  }
}
