//
//  WeatherListCoordinator.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit

enum WeatherListStep: StepProtocol {
  case list
  case emptyList
  case weatherDetails(identifier: Int?)
  case none
}

final class WeatherListCoordinator: Coordinator {
  
  // MARK: - Required Properties
  
  private static var _rootViewController: UINavigationController = {
    let navigationController = UINavigationController()
    navigationController.navigationBar.backgroundColor = .white
    navigationController.navigationBar.barTintColor = .black
    navigationController.navigationBar.tintColor = Constants.Theme.BrandColors.standardDay
    
    navigationController.tabBarItem.selectedImage = R.image.tabbar_list_ios11()
    navigationController.tabBarItem.image = R.image.tabbar_list_ios11()
    navigationController.tabBarItem.title = R.string.localizable.tab_weatherList()
    
    return navigationController
  }()
  
  private static var _stepper: WeatherListStepper = {
    let initalStep = InitialStep(
      identifier: WeatherListStep.identifier,
      step: WeatherDataService.shared.hasDisplayableData ? WeatherListStep.list : WeatherListStep.emptyList
    )
    return WeatherListStepper(initialStep: initalStep, type: WeatherListStep.self)
  }()
  
  // MARK: - Initialization
  
  init(parentCoordinator: Coordinator?) {
    super.init(
      rootViewController: Self._rootViewController,
      stepper: Self._stepper,
      parentCoordinator: parentCoordinator,
      type: WeatherListStep.self
    )
  }
  
  // MARK: - Navigation
  
  @objc override func didReceiveStep(_ notification: Notification) {
    super.didReceiveStep(notification, type: WeatherListStep.self)
  }
  
  override func executeRoutingStep(_ step: StepProtocol, passNextChildCoordinatorTo coordinatorReceiver: @escaping (NextCoordinator) -> Void) {
    guard let step = step as? WeatherListStep else { return }
    switch step {
    case .list:
      summonWeatherListController(passNextChildCoordinatorTo: coordinatorReceiver)
    case .emptyList:
      summonEmptyWeatherListController(passNextChildCoordinatorTo: coordinatorReceiver)
    case let .weatherDetails(identifier):
      summonWeatherDetailsController(weatherDetailIdentifier: identifier,
                                     passNextChildCoordinatorTo: coordinatorReceiver)
    case .none:
      break
    }
  }
}

private extension WeatherListCoordinator {
  
  func summonWeatherListController(passNextChildCoordinatorTo coordinatorReceiver: (NextCoordinator) -> Void) {
    let weatherListViewController = WeatherListViewController(style: .grouped)
    weatherListViewController.stepper = stepper as? WeatherListStepper
    
    weatherListViewController.title = R.string.localizable.tab_weatherList()
    
    let root = rootViewController as? UINavigationController
    root?.setViewControllers([weatherListViewController], animated: false)
    
    coordinatorReceiver(.none)
  }
  
  func summonEmptyWeatherListController(passNextChildCoordinatorTo coordinatorReceiver: (NextCoordinator) -> Void) {
    let emptyWeatherListViewController = R.storyboard.emptyWeatherList.emptyWeatherListViewController()!
    emptyWeatherListViewController.stepper = stepper as? WeatherListStepper
    
    emptyWeatherListViewController.title = R.string.localizable.tab_weatherList()

    let root = rootViewController as? UINavigationController
    root?.setViewControllers([emptyWeatherListViewController], animated: false)

    coordinatorReceiver(.none)
  }
  
  func summonWeatherDetailsController(weatherDetailIdentifier: Int?, passNextChildCoordinatorTo coordinatorReceiver: @escaping (NextCoordinator) -> Void) {
    let weatherDetailCoordinator = WeatherDetailCoordinator(parentCoordinator: self, weatherDetailIdentifier: weatherDetailIdentifier)

    guard let nextRoot = weatherDetailCoordinator.rootViewController as? UINavigationController else { return }
    rootViewController.present(nextRoot, animated: true)
    
    coordinatorReceiver(.single(weatherDetailCoordinator))
  }
}
