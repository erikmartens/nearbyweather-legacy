//
//  AppRouter.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 01.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit

enum MainCoordinatorStep: String, Step {
  case initial
  case none
}

final class MainCoordinator: Coordinator {
  
  // MARK: - Common Properties
  
  lazy var rootViewController: UIViewController = {
    let tabbar = UITabBarController()
    tabbar.tabBar.backgroundColor = .white
    tabbar.tabBar.barTintColor = .white
    tabbar.tabBar.tintColor = .nearbyWeatherStandard
    return tabbar
  }()
  
  var childCoordinators = [Coordinator]()
  
  // MARK: - Properties
  
  weak var appDelegate: AppDelegateProtocol?
  
  // MARK: - Initialization
  
  init(appDelegate: AppDelegateProtocol) {
    self.appDelegate = appDelegate
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(Self.didReceiveStep),
      name: Notification.Name(rawValue: Constants.Keys.NotificationCenter.kMainCoordinatorExeceuteRoutingStep),
      object: nil
    )
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Navigation
  
  @objc func didReceiveStep(_ notification: Notification) {
    guard let userInfo = notification.userInfo as? [String: String],
      let stepString = userInfo[Constants.Keys.AppCoordinator.kStep],
      let step = MainCoordinatorStep(rawValue: stepString) else {
        return
    }
    _ = navigateToStep(step)
  }
  
  func navigateToStep(_ step: Step) -> Coordinator? {
    guard let step = step as? MainCoordinatorStep else { return nil }
    
    switch step {
    case .initial:
      summonMainTabbarController()
      return nil
      return nil
    case .none:
      return nil
    }
  }
}

// MARK: - Navigation Helper Functions

extension MainCoordinator {
  
  func summonMainTabbarController() {
    let root = rootViewController as? UITabBarController
    
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
    
    root?.viewControllers = [weatherListNavigationController, mapNavigationController, settingsNavigationController]
    
    let window = UIWindow(frame: UIScreen.main.bounds)
    window.rootViewController = root
    window.makeKeyAndVisible()
    appDelegate?.window = window
  }
}
