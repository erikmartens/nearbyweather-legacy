//
//  WeatherListCoordinator.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit

enum WeatherListStep: StepProtocol {
  case initial
  case weatherDetails(identifier: Int?)
  case none
}

class WeatherListCoordinator: Coordinator {
  
  // MARK: - Required Properties
  
  private static var root: UINavigationController = {
    let navigationController = UINavigationController()
    navigationController.navigationBar.backgroundColor = .white
    navigationController.navigationBar.barTintColor = .black
    navigationController.navigationBar.tintColor = .nearbyWeatherStandard
    return navigationController
  }()
  
  override var initialStep: StepProtocol {
    return WeatherListStep.initial
  }
  
  override var associatedStepperIdentifier: String {
    return WeatherListStep.identifier
  }
  
  // MARK: - Initialization
  
  init(parentCoordinator: Coordinator?) {
    super.init(
      rootViewController: Self.root,
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
    case .initial:
      summonWeatherListController(passNextChildCoordinatorTo: coordinatorReceiver)
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
    let weatherListViewController = R.storyboard.weatherList.weatherListViewController()!
    weatherListViewController.stepper = WeatherListStepper(coordinator: self, type: WeatherListStep.self)
    
    weatherListViewController.title = R.string.localizable.tab_weatherList()
    weatherListViewController.tabBarItem.selectedImage = R.image.tabbar_list_ios11()
    weatherListViewController.tabBarItem.image = R.image.tabbar_list_ios11()
    
    let root = rootViewController as? UINavigationController
    root?.setViewControllers([weatherListViewController], animated: false)
    
    coordinatorReceiver(.none)
  }
  
  func summonWeatherDetailsController(weatherDetailIdentifier: Int?, passNextChildCoordinatorTo coordinatorReceiver: @escaping (NextCoordinator) -> Void) {
    let weatherDetailCoordinator = WeatherDetailCoordinator(parentCoordinator: self, weatherDetailIdentifier: weatherDetailIdentifier)
    
//    let closeButton = UIBarButtonItem(
//      image: R.image.verticalCloseButton(),
//      style: .plain,
//      target: self,
//      action: #selector(dismissWeatherDetailFlow)
//    )

    guard let nextRoot = weatherDetailCoordinator.rootViewController as? UINavigationController else {
      return
    }
//    nextRoot.navigationItem.leftBarButtonItem = closeButton
    rootViewController.present(nextRoot, animated: true)
    coordinatorReceiver(.single(weatherDetailCoordinator))
    
  }
  
//  @objc private func dismissWeatherDetailFlow() {
//
//  }
}
