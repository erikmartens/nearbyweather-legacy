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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        NetworkingService.instantiateSharedInstance()
        LocationService.instantiateSharedInstance()
        PreferencesManager.instantiateSharedInstance()
        WeatherLocationService.instantiateSharedInstance()
        WeatherDataManager.instantiateSharedInstance()
        
        /* UITabBar Appearance */
        
        UITabBar.appearance().backgroundColor = .white
        UITabBar.appearance().barTintColor = .white
        UITabBar.appearance().tintColor = .nearbyWeatherStandard
        
        let tabbar = self.window?.rootViewController as? UITabBarController
        
        /* Weather List Controller */
        let weatherListNav = R.storyboard.list().instantiateInitialViewController()
        let weatherList = (weatherListNav as? UINavigationController)?.viewControllers.first as? WeatherListViewController
        weatherList?.title = R.string.localizable.tab_weatherList().uppercased()
        weatherList?.tabBarItem.selectedImage = R.image.cloudCoverFilled()
        weatherList?.tabBarItem.image = R.image.cloudCoverFilled()
        
        /* Map Controller */
        let mapNav = R.storyboard.map().instantiateInitialViewController()
        let map = (mapNav as? UINavigationController)?.viewControllers.first as? NearbyLocationsMapViewController
        map?.title = R.string.localizable.tab_weatherMap().uppercased()
        map?.tabBarItem.selectedImage = R.image.map()
        map?.tabBarItem.image = R.image.map()

        /* Settings Controller */
        let settingsNav = R.storyboard.settings().instantiateInitialViewController()
        let settings = (settingsNav as? UINavigationController)?.viewControllers.first as? SettingsTableViewController
        settings?.title = R.string.localizable.tab_settings().uppercased()
        settings?.tabBarItem.selectedImage = R.image.settings()
        settings?.tabBarItem.image = R.image.settings()

        tabbar?.viewControllers = [weatherListNav!, mapNav!, settingsNav!]
        
        
        if UserDefaults.standard.value(forKey: kNearbyWeatherApiKeyKey) == nil {
            showSplashScreenIfNeeded()
        } else {
            LocationService.shared.requestWhenInUseAuthorization()
        }
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        refreshWeatherDataIfNeeded()
    }
    
    
    // MARK: - Private Helpers
    
    private func refreshWeatherDataIfNeeded() {
        if UserDefaults.standard.value(forKey: kNearbyWeatherApiKeyKey) != nil,
            UserDefaults.standard.bool(forKey: kRefreshOnAppStartKey) == true {
            WeatherDataManager.shared.update(withCompletionHandler: nil)
        }
    }
    
    func showSplashScreenIfNeeded() {
        let splashScreenWindow = UIWindow(frame: window!.bounds)
        let welcomeNav = R.storyboard.welcome().instantiateInitialViewController() as? WelcomeNavigationController
        welcomeNav?.welcomeNavigationDelegate = self
        splashScreenWindow.windowLevel = UIWindowLevelAlert
        
        splashScreenWindow.rootViewController = welcomeNav
        self.splashScreenWindow = splashScreenWindow
        self.splashScreenWindow?.makeKeyAndVisible()
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
