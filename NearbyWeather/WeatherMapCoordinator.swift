//
//  WeatherMapCoordinator.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 08.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit

enum WeatherMapStep: StepProtocol {
  case initial
  case weatherDetails
  case none
}

class WeatherMapCoordinator: Coordinator {
  
  // MARK: - Required Properties
  
  private static var root: UINavigationController = {
    let navigationController = UINavigationController()
    navigationController.navigationBar.backgroundColor = .white
    navigationController.navigationBar.barTintColor = .black
    navigationController.navigationBar.tintColor = .nearbyWeatherStandard
    return navigationController
  }()
  
  override var initialStep: StepProtocol {
    return WeatherMapStep.initial
  }
  
  override var associatedStepperIdentifier: String {
    return WeatherMapStep.identifier
  }
  
  // MARK: - Initialization
  
  init(parentCoordinator: Coordinator?) {
    super.init(
      rootViewController: Self.root,
      parentCoordinator: parentCoordinator,
      type: WeatherMapStep.self
    )
  }
  
  // MARK: - Navigation
  
  @objc override func didReceiveStep(_ notification: Notification) {
    super.didReceiveStep(notification, type: WeatherMapStep.self)
  }
  
  override func executeRoutingStep(_ step: StepProtocol, nextCoordinatorReceiver receiver: (NextCoordinator) -> Void) {
    guard let step = step as? WeatherMapStep else { return }
    switch step {
    case .initial:
      summonWeatherMapController(nextCoordinatorReceiver: receiver)
    case .weatherDetails:
      break // TODO
    case .none:
      break
    }
  }
}

private extension WeatherMapCoordinator {
  
  func summonWeatherMapController(nextCoordinatorReceiver: (NextCoordinator) -> Void) {
    let mapViewController = R.storyboard.weatherMap.nearbyLocationsMapViewController()!
    mapViewController.title = R.string.localizable.tab_weatherMap().uppercased()
    
    mapViewController.tabBarItem.selectedImage = R.image.tabbar_map_ios11()
    mapViewController.tabBarItem.image = R.image.tabbar_map_ios11()
    
    (rootViewController as? UINavigationController)?.setViewControllers([mapViewController], animated: false)
  }
}
