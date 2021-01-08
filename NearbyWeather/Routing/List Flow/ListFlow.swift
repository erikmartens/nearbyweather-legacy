//
//  ListFlow.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxFlow
import Swinject

final class ListFlow: Flow {
  
  // MARK: - Assets
  
  var root: Presentable {
    rootViewController
  }
  
  private lazy var rootViewController: UINavigationController = {
    let navigationController = Factory.NavigationController.make(fromType: .standard)
    navigationController.tabBarItem.image = R.image.tabbar_list_ios11()
    navigationController.tabBarItem.title = R.string.localizable.tab_weatherList()
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
    guard let step = transform(step: step) as? ListStep else {
      return .none
    }
    switch step {
    case .list:
      return summonWeatherListController()
    case .emptyList:
      return summonEmptyWeatherListController()
    case let .weatherDetails(identifier, isBookmark):
      return summonWeatherDetailsController(identifier: identifier, isBookmark: isBookmark)
    case let .weatherDetails2(identity, isBookmark):
      return summonWeatherDetailsController2(identity: identity, isBookmark: isBookmark)
    case let .changeListTypeAlert(currentSelectedOptionValue):
      return summonChangeListTypeAlert(currentSelectedOptionValue: currentSelectedOptionValue)
    case let .changeAmountOfResultsAlert(currentSelectedOptionValue):
      return summonChangeAmountOfResultsAlert(currentSelectedOptionValue: currentSelectedOptionValue)
    case let .changeSortingOrientationAlert(currentSelectedOptionValue):
      return summonChangeSortingOrientationAlert(currentSelectedOptionValue: currentSelectedOptionValue)
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
        return ListStep.dismissChildFlow
      }
    }
    return step
  }
}

private extension ListFlow {
  
  func summonWeatherListController() -> FlowContributors {
    let weatherListViewController = WeatherListViewController(dependencies: WeatherListViewController.ViewModel.Dependencies(
      weatherInformationService: dependencyContainer.resolve(WeatherInformationService2.self)!,
      weatherStationService: dependencyContainer.resolve(WeatherStationService2.self)!,
      userLocationService: dependencyContainer.resolve(UserLocationService2.self)!,
      preferencesService: dependencyContainer.resolve(PreferencesService2.self)!
    ))
    rootViewController.setViewControllers([weatherListViewController], animated: false)
    return .one(flowContributor: .contribute(withNextPresentable: weatherListViewController, withNextStepper: weatherListViewController.viewModel))
  }
  
  func summonEmptyWeatherListController() -> FlowContributors {
    let emptyWeatherListViewController = R.storyboard.emptyList.emptyListViewController()!
    rootViewController.setViewControllers([emptyWeatherListViewController], animated: false)
    return .none
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
  
  func summonChangeListTypeAlert(currentSelectedOptionValue: ListTypeValue) -> FlowContributors { // TODO: test cancel action works properly
    let preferencesService = dependencyContainer.resolve(PreferencesService2.self)!
    
    let alertController = ListTypeSelectionAlertController(dependencies: ListTypeSelectionViewModel.Dependencies(
      selectedOptionValue: currentSelectedOptionValue,
      preferencesService: preferencesService
    ))
    rootViewController.present(alertController, animated: true, completion: nil)
    return .one(flowContributor: .contribute(withNextPresentable: alertController, withNextStepper: alertController.viewModel))
  }
  
  func summonChangeAmountOfResultsAlert(currentSelectedOptionValue: AmountOfResultsValue) -> FlowContributors {
    let preferencesService = dependencyContainer.resolve(PreferencesService2.self)!
    
    let alertController = AmountOfNearbyResultsSelectionAlertController(dependencies: AmountOfNearbyResultsSelectionViewModel.Dependencies(
      selectedOptionValue: currentSelectedOptionValue,
      preferencesService: preferencesService
    ))
    rootViewController.present(alertController, animated: true, completion: nil)
    return .one(flowContributor: .contribute(withNextPresentable: alertController, withNextStepper: alertController.viewModel))
  }
  
  func summonChangeSortingOrientationAlert(currentSelectedOptionValue: SortingOrientationValue) -> FlowContributors {
    let preferencesService = dependencyContainer.resolve(PreferencesService2.self)!
    
    let alertController = SortingOrientationSelectionAlertController(dependencies: SortingOrientationSelectionViewModel.Dependencies(
      selectedOptionValue: currentSelectedOptionValue,
      preferencesService: preferencesService
    ))
    rootViewController.present(alertController, animated: true, completion: nil)
    return .one(flowContributor: .contribute(withNextPresentable: alertController, withNextStepper: alertController.viewModel))
  }
  
  func dismissChildFlow() -> FlowContributors {
    rootViewController.presentedViewController?.dismiss(animated: true, completion: nil)
    return .none
  }
}
