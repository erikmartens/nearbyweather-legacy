//
//  WeatherDetailFlow.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxFlow
import Swinject

// MARK: - Dependencies

extension WeatherDetailFlow {
  struct Dependencies {
    let weatherInformationIdentity: PersistencyModelIdentity
    let dependencyContainer: Container
  }
}

// MARK: - Class Definition

final class WeatherDetailFlow: Flow {
  
  // MARK: - Assets
  
  var root: Presentable {
    rootViewController
  }
  
  private lazy var rootViewController = Factory.NavigationController.make(fromType: .standard)
  
  // MARK: - Dependencies
  
  private let dependencies: Dependencies
  
  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }
  
  deinit {
    printDebugMessage(
      domain: String(describing: self),
      message: "was deinitialized",
      type: .info
    )
  }
  
  // MARK: - Functions
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? WeatherDetailStep else {
      return .none
    }
    switch step {
    case .weatherDetails:
      return summonWeatherDetailController()
    case .dismiss:
      return dismissWeatherDetailController()
    }
  }
}

// MARK: - Summoning Functions

private extension WeatherDetailFlow {
  
  func summonWeatherDetailController() -> FlowContributors {
    let weatherDetailViewController = WeatherStationMeteorologyDetailsViewController(dependencies: WeatherStationMeteorologyDetailsViewModel.Dependencies(
      weatherInformationIdentity: dependencies.weatherInformationIdentity,
      weatherStationService: dependencies.dependencyContainer.resolve(WeatherStationService2.self)!,
      weatherInformationService: dependencies.dependencyContainer.resolve(WeatherInformationService2.self)!,
      preferencesService: dependencies.dependencyContainer.resolve(PreferencesService2.self)!,
      userLocationService: dependencies.dependencyContainer.resolve(UserLocationService2.self)!
    ))
    
    rootViewController.setViewControllers([weatherDetailViewController], animated: false)
    return .one(flowContributor: .contribute(withNextPresentable: weatherDetailViewController, withNextStepper: weatherDetailViewController.viewModel))
  }
  
  func dismissWeatherDetailController() -> FlowContributors {
    .end(forwardToParentFlowWithStep: WeatherDetailStep.dismiss)
  }
}
