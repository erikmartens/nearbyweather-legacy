//
//  AppRouter.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 01.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit

enum MainCoordinatorStep: StepProtocol {
  case initial
  case none
}

final class MainCoordinator: Coordinator {
  
  // MARK: - Common Properties
  
  override var rootViewController: UIViewController {
    return root
  }
  
  private lazy var root: UITabBarController = {
    let tabbar = UITabBarController()
    tabbar.tabBar.backgroundColor = .white
    tabbar.tabBar.barTintColor = .white
    tabbar.tabBar.tintColor = .nearbyWeatherStandard
    return tabbar
  }()
  
  // MARK: - Properties
  
  weak var windowManager: WindowManager?
  
  // MARK: - Initialization
  
  init(windowManager: WindowManager) {
    super.init(parentCoordinator: nil, type: MainCoordinatorStep.self)
    self.windowManager = windowManager
  }
  
  // MARK: - Navigation
  
  @objc override func didReceiveStep(_ notification: Notification) {
    super.didReceiveStep(notification, type: MainCoordinatorStep.self)
  }
  
  override func executeRoutingStep(_ step: StepProtocol, nextCoordinatorReceiver receiver: (NextCoordinator) -> Void) {
    guard let step = step as? MainCoordinatorStep else { return }
    switch step {
    case .initial:
      summonMainTabbarController(nextCoordinatorReceiver: receiver)
    case .none:
      break
    }
  }
}

// MARK: - Navigation Helper Functions

private extension MainCoordinator {
  
  func summonMainTabbarController(nextCoordinatorReceiver: (NextCoordinator) -> Void) {
    let root = rootViewController as? UITabBarController
    
    /* Weather List Controller */
    let weatherListViewController = R.storyboard.weatherList.weatherListViewController()!
    let weatherListNavigationController = UINavigationController(rootViewController: weatherListViewController)
    weatherListViewController.title = R.string.localizable.tab_weatherList().uppercased()
    weatherListViewController.tabBarItem.selectedImage = R.image.tabbar_list_ios11()
    weatherListViewController.tabBarItem.image = R.image.tabbar_list_ios11()
    
    /* Map Controller */
    let mapViewController = R.storyboard.weatherMap.nearbyLocationsMapViewController()!
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
    windowManager?.window = window
  }
}
