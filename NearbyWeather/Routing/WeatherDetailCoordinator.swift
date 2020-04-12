//
//  WeatherDetailCoordinator.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit

enum WeatherDetailStep: StepProtocol {
  case initial(identifier: Int?, isBookmark: Bool)
  case dismiss
  case none
}

final class WeatherDetailCoordinator: Coordinator {
  
  // MARK: - Required Properties
  
  private static var _rootViewController: UINavigationController = {
    let navigationController = UINavigationController()
    navigationController.navigationBar.backgroundColor = .white
    navigationController.navigationBar.barTintColor = .black
    navigationController.navigationBar.tintColor = Constants.Theme.BrandColors.standardDay
    return navigationController
  }()
  
  // MARK: - Initialization
  
  init(parentCoordinator: Coordinator?, weatherDetailIdentifier: Int?, isBookmark: Bool) {
    let initialStep = InitialStep(
      identifier: WeatherDetailStep.identifier,
      step: WeatherDetailStep.initial(identifier: weatherDetailIdentifier, isBookmark: isBookmark)
    )
    
    super.init(
      rootViewController: Self._rootViewController,
      stepper: WeatherDetailStepper(initialStep: initialStep, type: WeatherListStep.self),
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
    case let .initial(identifier, isBookmark):
      summonWeatherDetailController(weatherDataIdentifier: identifier,
                                    isBookmark: isBookmark,
                                    passNextChildCoordinatorTo: coordinatorReceiver)
    case .dismiss:
      dismissWeatherDetailController(passNextChildCoordinatorTo: coordinatorReceiver)
    case .none:
      break
    }
  }
}

private extension WeatherDetailCoordinator {
  
  func summonWeatherDetailController(weatherDataIdentifier: Int?, isBookmark: Bool, passNextChildCoordinatorTo coordinatorReceiver: (NextCoordinator) -> Void) {
    guard let weatherDataIdentifier = weatherDataIdentifier,
      let weatherDTO = WeatherDataService.shared.weatherDTO(forIdentifier: weatherDataIdentifier) else {
        return
    }
    
    let destinationViewController = WeatherDetailViewController.instantiateFromStoryBoard(
      withTitle: weatherDTO.cityName,
      weatherDTO: weatherDTO,
      isBookmark: isBookmark
    )
    destinationViewController.stepper = stepper as? WeatherDetailStepper
    
    destinationViewController.addBarButton(atPosition: .left) { [weak self] in
      (self?.stepper as? WeatherDetailStepper)?.requestRouting(toStep: .dismiss)
    }
    
    let root = rootViewController as? UINavigationController
    //    root?.delegate = self
    root?.setViewControllers([destinationViewController], animated: false)
    
    coordinatorReceiver(.none)
  }
  
  func dismissWeatherDetailController(passNextChildCoordinatorTo coordinatorReceiver: @escaping (NextCoordinator) -> Void) {
    parentCoordinator?.rootViewController.dismiss(animated: true, completion: {
      coordinatorReceiver(.destroy(self))
    })
  }
}

//extension WeatherDetailCoordinator: UINavigationControllerDelegate {
//  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
//
//  }
//}
