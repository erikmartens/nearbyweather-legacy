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
  case apiKeyEdit
  case manageLocations
  case addLocation
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
    case .apiKeyEdit:
      summonApiKeyEditController(passNextChildCoordinatorTo: coordinatorReceiver)
    case .manageLocations:
      summonManageLocationsController(passNextChildCoordinatorTo: coordinatorReceiver)
    case .addLocation:
      summonAddLocationController(passNextChildCoordinatorTo: coordinatorReceiver)
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
  
  func summonApiKeyEditController(passNextChildCoordinatorTo coordinatorReceiver: (NextCoordinator) -> Void) {
    let apiKeyEditController = SettingsInputTableViewController(style: .grouped)
    apiKeyEditController.navigationItem.title = R.string.localizable.api_settings()
    apiKeyEditController.stepper = stepper
    
    let root = rootViewController as? UINavigationController
    root?.pushViewController(apiKeyEditController, animated: true)
    
    coordinatorReceiver(.none)
  }
  
  func summonManageLocationsController(passNextChildCoordinatorTo coordinatorReceiver: (NextCoordinator) -> Void) {
    guard !WeatherDataManager.shared.bookmarkedLocations.isEmpty else { return }
    let locationManagementController = WeatherLocationManagementTableViewController(style: .grouped)
    locationManagementController.navigationItem.title = R.string.localizable.manage_locations()
    locationManagementController.stepper = stepper
    
    let root = rootViewController as? UINavigationController
    root?.pushViewController(locationManagementController, animated: true)
    
    coordinatorReceiver(.none)
  }
  
  func summonAddLocationController(passNextChildCoordinatorTo coordinatorReceiver: (NextCoordinator) -> Void) {
    let addLocationController = WeatherLocationSelectionTableViewController(style: .grouped)
    addLocationController.navigationItem.title = R.string.localizable.add_location()
    addLocationController.stepper = stepper
    
    let root = rootViewController as? UINavigationController
    root?.pushViewController(addLocationController, animated: true)
    
    coordinatorReceiver(.none)
  }
}
