//
//  MapFlow.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxFlow
import Swinject

final class MapFlow: Flow {
  
  // MARK: - Assets
  
  var root: Presentable {
    rootViewController
  }
  
  private lazy var rootViewController: UINavigationController = {
    let navigationController = Factory.NavigationController.make(fromType: .standard)
    
    navigationController.tabBarItem.image = R.image.tabbar_map_ios11()
    navigationController.tabBarItem.title = R.string.localizable.tab_weatherMap()
    
    return navigationController
  }()
  
  // MARK: - Properties
  
  let dependencyContainer: Container

  // MARK: - Initialization

  init(dependencyContainer: Container) {
    self.dependencyContainer = dependencyContainer
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
    guard let step = transform(step: step) as? MapStep else {
      return .none
    }
    switch step {
    case .map:
      return summonWeatherMapController()
    case let .weatherDetails(identifier, isBookmark):
      return summonWeatherDetailsController(identifier: identifier, isBookmark: isBookmark)
    case let .weatherDetails2(identity, isBookmark):
      return summonWeatherDetailsController2(identity: identity, isBookmark: isBookmark)
    case let .changeMapTypeAlert(currentSelectedOptionValue):
      return summonChangeMapTypeAlert(currentSelectedOptionValue: currentSelectedOptionValue)
    case let .changeAmountOfResultsAlert(currentSelectedOptionValue):
      return summonChangeAmountOfResultsAlert(currentSelectedOptionValue: currentSelectedOptionValue)
    case .focusOnLocationAlert:
      return summonFocusOnLocationAlert()
    case .dismissChildFlow:
      return dismissChildFlow()
    }
  }
  
  private func transform(step: Step) -> Step? {
    if let weatherDetailStep = step as? WeatherDetailStep {
      switch weatherDetailStep {
      case .weatherDetail:
        return nil
      case .dismiss:
        return MapStep.dismissChildFlow
      }
    }
    return step
  }
}

private extension MapFlow {
  
  func summonWeatherMapController() -> FlowContributors {
    let mapViewController = MapViewController()
    rootViewController.setViewControllers([mapViewController], animated: false)
    return .one(flowContributor: .contribute(withNext: mapViewController))
  }
  
  func summonWeatherDetailsController(identifier: Int?, isBookmark: Bool) -> FlowContributors {
    guard let identifier = identifier else {
      return .none
    }
    let weatherDetailFlow = WeatherDetailFlow(dependencies: WeatherDetailFlow.Dependencies(
      identifier: identifier,
      isBookmark: isBookmark
    ))
    
    Flows.whenReady(flow1: weatherDetailFlow) { [rootViewController] (weatherDetailRoot: UINavigationController) in
      rootViewController.present(weatherDetailRoot, animated: true)
    }
    
    return .one(flowContributor: .contribute(withNextPresentable: weatherDetailFlow, withNextStepper: WeatherDetailStepper()))
  }
  
  func summonWeatherDetailsController2(identity: PersistencyModelIdentityProtocol, isBookmark: Bool) -> FlowContributors {
    .none // TODO
  }
  
  func summonChangeMapTypeAlert(currentSelectedOptionValue: MapTypeValue) -> FlowContributors { // TODO: test cancel action works properly
    let preferencesService = dependencyContainer.resolve(PreferencesService2.self)!
    
    let alertController = MapTypeSelectionAlertController(dependencies: MapTypeSelectionAlertViewModel.Dependencies(
      selectedOptionValue: currentSelectedOptionValue,
      preferencesService: preferencesService
    ))
    rootViewController.present(alertController, animated: true, completion: nil)
    return .one(flowContributor: .contribute(withNextPresentable: alertController, withNextStepper: alertController.viewModel))
  }
  
  func summonChangeAmountOfResultsAlert(currentSelectedOptionValue: AmountOfResultsValue) -> FlowContributors {
    let preferencesService = dependencyContainer.resolve(PreferencesService2.self)!
    
    let alertController = AmountOfNearbyResultsSelectionAlertController(dependencies: AmountOfNearbyResultsSelectionAlertViewModel.Dependencies(
      selectedOptionValue: currentSelectedOptionValue,
      preferencesService: preferencesService
    ))
    rootViewController.present(alertController, animated: true, completion: nil)
    return .one(flowContributor: .contribute(withNextPresentable: alertController, withNextStepper: alertController.viewModel))
  }
  
  func summonFocusOnLocationAlert() -> FlowContributors {
    .none // TODO
  }
  
  func dismissChildFlow() -> FlowContributors {
    rootViewController.presentedViewController?.dismiss(animated: true, completion: nil)
    return .none
  }
}
