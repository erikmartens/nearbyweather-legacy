//
//  SettingsCoordinator.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 08.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit

enum SettingsStep: StepProtocol {
  case initial
  case about
  case none
}

class SettingsCoordinator: Coordinator {
  
  // MARK: - Required Properties
  
  private static var root: UINavigationController = {
    let navigationController = UINavigationController()
    navigationController.navigationBar.backgroundColor = .white
    navigationController.navigationBar.barTintColor = .black
    navigationController.navigationBar.tintColor = .nearbyWeatherStandard
    return navigationController
  }()
  
  override var initialStep: StepProtocol {
    return SettingsStep.initial
  }
  
  override var associatedStepperIdentifier: String {
    return SettingsStep.identifier
  }
  
  // MARK: - Additional Properties
  
  private lazy var stepper: SettingsStepper = {
    SettingsStepper(coordinator: self, type: SettingsStep.self)
  }()
  
  // MARK: - Initialization
  
  init(parentCoordinator: Coordinator?) {
    super.init(
      rootViewController: Self.root,
      parentCoordinator: parentCoordinator,
      type: SettingsStep.self
    )
  }
  
  // MARK: - Navigation
  
  @objc override func didReceiveStep(_ notification: Notification) {
    super.didReceiveStep(notification, type: SettingsStep.self)
  }
  
  override func executeRoutingStep(_ step: StepProtocol, passNextChildCoordinatorTo coordinatorReceiver: @escaping (NextCoordinator) -> Void) {
    guard let step = step as? SettingsStep else { return }
    switch step {
    case .initial:
      summonSettingsController(passNextChildCoordinatorTo: coordinatorReceiver)
    case .about:
      summonAboutController(passNextChildCoordinatorTo: coordinatorReceiver)
    case .none:
      break
    }
  }
}

private extension SettingsCoordinator {
  
  func summonSettingsController(passNextChildCoordinatorTo coordinatorReceiver: (NextCoordinator) -> Void) {
    let settingsViewController = SettingsTableViewController(style: .grouped)
    settingsViewController.title = R.string.localizable.tab_settings()
    settingsViewController.stepper = stepper
    
    settingsViewController.tabBarItem.selectedImage = R.image.tabbar_settings_ios11()
    settingsViewController.tabBarItem.image = R.image.tabbar_settings_ios11()

    (rootViewController as? UINavigationController)?.setViewControllers([settingsViewController], animated: false)
    
    coordinatorReceiver(.none)
  }
  
  func summonAboutController(passNextChildCoordinatorTo coordinatorReceiver: (NextCoordinator) -> Void) {
    let aboutController = R.storyboard.aboutApp.infoTableViewController()!
    aboutController.navigationItem.title = R.string.localizable.about()
    aboutController.stepper = stepper
    
    let root = rootViewController as? UINavigationController
    root?.pushViewController(aboutController, animated: true)
    
    coordinatorReceiver(.none)
  }
}
