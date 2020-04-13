//
//  AppRouter.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 01.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit

enum MainStep: StepProtocol {
  case initial
  case none
}

final class MainCoordinator: Coordinator {
  
  // MARK: - Required Properties
  
  private static var _rootViewController: UITabBarController = {
    let tabbar = UITabBarController()
    tabbar.tabBar.backgroundColor = .white
    tabbar.tabBar.barTintColor = .white
    tabbar.tabBar.tintColor = Constants.Theme.Color.BrandColors.standardDay
    return tabbar
  }()
  
  private static var _stepper: MainStepper = {
    let initialStep = InitialStep(
      identifier: MainStep.identifier,
      step: MainStep.initial
    )
    return MainStepper(initialStep: initialStep, type: MainStep.self)
  }()
  
  // MARK: - Additional Properties
  
  weak var windowManager: MainWindowManager?
  
  // MARK: - Initialization
  
  init(parentCoordinator: Coordinator?, windowManager: MainWindowManager) {
    self.windowManager = windowManager
    
    super.init(
      rootViewController: Self._rootViewController,
      stepper: Self._stepper,
      parentCoordinator: parentCoordinator,
      type: MainStep.self
    )
  }
  
  // MARK: - Navigation
  
  @objc override func didReceiveStep(_ notification: Notification) {
    super.didReceiveStep(notification, type: MainStep.self)
  }
  
  override func executeRoutingStep(_ step: StepProtocol, passNextChildCoordinatorTo coordinatorReceiver: @escaping (NextCoordinator) -> Void) {
    guard let step = step as? MainStep else { return }
    switch step {
    case .initial:
      summonMainTabbarController(passNextChildCoordinatorTo: coordinatorReceiver)
    case .none:
      break
    }
  }
}

// MARK: - Navigation Helper Functions

private extension MainCoordinator {
  
  func summonMainTabbarController(passNextChildCoordinatorTo coordinatorReceiver: (NextCoordinator) -> Void) {
    let root = rootViewController as? UITabBarController
    
    let weatherList = WeatherListCoordinator(parentCoordinator: self)
    let weatherMap = WeatherMapCoordinator(parentCoordinator: self)
    let settings = SettingsCoordinator(parentCoordinator: self)

    root?.viewControllers = [weatherList.rootViewController, weatherMap.rootViewController, settings.rootViewController]
    
    let window = UIWindow(frame: UIScreen.main.bounds)
    window.rootViewController = root
    window.makeKeyAndVisible()
    windowManager?.window = window
    
    coordinatorReceiver(
      .multiple([weatherList, weatherMap, settings])
    )
  }
}
