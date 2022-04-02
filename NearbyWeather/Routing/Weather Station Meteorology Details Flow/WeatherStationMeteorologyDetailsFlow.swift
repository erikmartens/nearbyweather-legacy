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

extension WeatherStationMeteorologyDetailsFlow {
  struct Dependencies {
    let flowPresentationStyle: FlowPresentationStyle
    let endingStep: Step
    let weatherInformationIdentity: PersistencyModelIdentity
    let dependencyContainer: Container
  }
}

// MARK: - Class Definition

final class WeatherStationMeteorologyDetailsFlow: Flow {
  
  // MARK: - Assets
  
  var root: Presentable {
    rootViewController
  }
  
  private lazy var rootViewController: UINavigationController = {
    switch dependencies.flowPresentationStyle {
    case let .pushed(rootViewController):
      return rootViewController
    case .presented:
      return Factory.NavigationController.make(fromType: .standard)
    }
  }()
  
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
    guard let step = step as? WeatherStationMeteorologyDetailsStep else {
      return .none
    }
    switch step {
    case .weatherStationMeteorologyDetails:
      return summonWeatherStationMeteorologyDetailsController()
    case .end:
      return dismissWeatherDetailController()
    }
  }
}

// MARK: - Summoning Functions

private extension WeatherStationMeteorologyDetailsFlow {
  
  func summonWeatherStationMeteorologyDetailsController() -> FlowContributors {
    let weatherDetailViewController = WeatherStationMeteorologyDetailsViewController(dependencies: WeatherStationMeteorologyDetailsViewModel.Dependencies(
      weatherInformationIdentity: dependencies.weatherInformationIdentity,
      weatherStationService: dependencies.dependencyContainer.resolve(WeatherStationService.self)!,
      weatherInformationService: dependencies.dependencyContainer.resolve(WeatherInformationService.self)!,
      preferencesService: dependencies.dependencyContainer.resolve(PreferencesService.self)!,
      userLocationService: dependencies.dependencyContainer.resolve(UserLocationService.self)!
    ))
    
    switch dependencies.flowPresentationStyle {
    case .pushed:
      rootViewController.pushViewController(weatherDetailViewController, animated: true)
    case .presented:
      rootViewController.setViewControllers([weatherDetailViewController], animated: false)
    }
    return .one(flowContributor: .contribute(withNextPresentable: weatherDetailViewController, withNextStepper: weatherDetailViewController.viewModel))
  }
  
  func dismissWeatherDetailController() -> FlowContributors {
    .end(forwardToParentFlowWithStep: dependencies.endingStep)
  }
}
