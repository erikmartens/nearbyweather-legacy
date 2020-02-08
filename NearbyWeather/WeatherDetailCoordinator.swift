//
//  WeatherDetailCoordinator.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit

enum WeatherDetailStep: StepProtocol {
  case initial(identifier: Int?)
  case dismiss
  case none
}

class WeatherDetailCoordinator: Coordinator {
  
  // MARK: - Required Properties
  
  private static var root: UINavigationController = {
    let navigationController = UINavigationController()
    navigationController.navigationBar.backgroundColor = .white
    navigationController.navigationBar.barTintColor = .black
    navigationController.navigationBar.tintColor = .nearbyWeatherStandard
    return navigationController
  }()
  
  override var initialStep: StepProtocol {
    return WeatherDetailStep.initial(identifier: weatherDetailIdentifier)
  }
  
  override var associatedStepperIdentifier: String {
    return WeatherDetailStep.identifier
  }
  
  // MARK: - Additional Properties
  
  private let weatherDetailIdentifier: Int?
  
  // MARK: - Initialization
  
  init(parentCoordinator: Coordinator?, weatherDetailIdentifier: Int?) {
    self.weatherDetailIdentifier = weatherDetailIdentifier
    
    super.init(
      rootViewController: Self.root,
      parentCoordinator: parentCoordinator,
      type: WeatherDetailStep.self
    )
  }
  
  // MARK: - Navigation
  
  @objc override func didReceiveStep(_ notification: Notification) {
    super.didReceiveStep(notification, type: WeatherDetailStep.self)
  }
  
  override func executeRoutingStep(_ step: StepProtocol, passNextChildCoordinatorTo coordinatorReceiver: @escaping (NextCoordinator) -> Void) {
    guard let step = step as? WeatherDetailStep else { return }
    switch step {
    case let .initial(identifier):
      summonWeatherDetailController(weatherDataIdentifier: identifier,
                                    passNextChildCoordinatorTo: coordinatorReceiver)
    case .dismiss:
      dismissWeatherDetailController(passNextChildCoordinatorTo: coordinatorReceiver)
    case .none:
      break
    }
  }
}

private extension WeatherDetailCoordinator {
  
  func summonWeatherDetailController(weatherDataIdentifier: Int?, passNextChildCoordinatorTo coordinatorReceiver: (NextCoordinator) -> Void) {
    guard let weatherDataIdentifier = weatherDataIdentifier,
      let weatherDTO = WeatherDataManager.shared.weatherDTO(forIdentifier: weatherDataIdentifier) else {
        return
    }
    
    let destinationViewController = WeatherDetailsViewController.instantiateFromStoryBoard(
      withTitle: weatherDTO.cityName,
      weatherDTO: weatherDTO
    )
    
    let root = rootViewController as? UINavigationController
    root?.setViewControllers([destinationViewController], animated: false)
    
    coordinatorReceiver(.none)
  }
  
  func dismissWeatherDetailController(passNextChildCoordinatorTo coordinatorReceiver: @escaping (NextCoordinator) -> Void) {
    parentCoordinator?.rootViewController.dismiss(animated: true, completion: {
      coordinatorReceiver(.destroy(self))
    })
  }
}
