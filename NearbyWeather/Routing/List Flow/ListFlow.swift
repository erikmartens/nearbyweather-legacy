//
//  ListFlow.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxFlow
import Swinject

// MARK: - Dependencies

extension ListFlow {
  struct Dependencies {
    let dependencyContainer: Container
  }
}

// MARK: - Class Definition

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
  
  let dependencies: Dependencies
  
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
    guard let step = transform(step: step) as? ListStep else {
      return .none
    }
    switch step {
    case .list:
      return summonWeatherListController()
    case .emptyList:
      return summonEmptyWeatherListController()
    case let .weatherDetails2(identity):
      return summonWeatherDetailsController2(identity: identity)
    case let .changeListTypeAlert(selectionDelegate, currentSelectedOptionValue):
      return summonChangeListTypeAlert(selectionDelegate: selectionDelegate, currentSelectedOptionValue: currentSelectedOptionValue)
    case let .changeAmountOfResultsAlert(selectionDelegate, currentSelectedOptionValue):
      return summonChangeAmountOfResultsAlert(selectionDelegate: selectionDelegate, currentSelectedOptionValue: currentSelectedOptionValue)
    case let .changeSortingOrientationAlert(selectionDelegate, currentSelectedOptionValue):
      return summonChangeSortingOrientationAlert(selectionDelegate: selectionDelegate, currentSelectedOptionValue: currentSelectedOptionValue)
    case .dismissChildFlow:
      return dismissChildFlow()
    }
  }
  
  private func transform(step: Step) -> Step? {
    if let weatherDetailStep = step as? WeatherDetailStep {
      switch weatherDetailStep {
      case .weatherDetails:
        return nil
      case .dismiss:
        return ListStep.dismissChildFlow
      }
    }
    return step
  }
}

// MARK: - Summoning Functions

private extension ListFlow {
  
  func summonWeatherListController() -> FlowContributors {
    let weatherListViewController = WeatherListViewController(dependencies: WeatherListViewController.ViewModel.Dependencies(
      weatherInformationService: dependencies.dependencyContainer.resolve(WeatherInformationService2.self)!,
      weatherStationService: dependencies.dependencyContainer.resolve(WeatherStationService2.self)!,
      userLocationService: dependencies.dependencyContainer.resolve(UserLocationService2.self)!,
      preferencesService: dependencies.dependencyContainer.resolve(PreferencesService2.self)!,
      apiKeyService: dependencies.dependencyContainer.resolve(ApiKeyService2.self)!
    ))
    rootViewController.setViewControllers([weatherListViewController], animated: false)
    return .one(flowContributor: .contribute(
      withNextPresentable: weatherListViewController,
      withNextStepper: weatherListViewController.viewModel,
      allowStepWhenNotPresented: true
    ))
  }
  
  func summonEmptyWeatherListController() -> FlowContributors {
    let emptyWeatherListViewController = R.storyboard.emptyList.emptyListViewController()!
    rootViewController.setViewControllers([emptyWeatherListViewController], animated: false)
    return .none
  }
  
  func summonWeatherDetailsController2(identity: PersistencyModelIdentityProtocol) -> FlowContributors {
    let weatherDetailFlow = WeatherDetailFlow(dependencies: WeatherDetailFlow.Dependencies(
      weatherInformationIdentity: identity,
      dependencyContainer: dependencies.dependencyContainer
    ))
    
    Flows.whenReady(flow1: weatherDetailFlow) { [rootViewController] (weatherDetailRoot: UINavigationController) in
      rootViewController.present(weatherDetailRoot, animated: true)
    }
    
    return .one(flowContributor: .contribute(withNextPresentable: weatherDetailFlow, withNextStepper: WeatherDetailStepper()))
  }
  
  func summonChangeListTypeAlert(selectionDelegate: ListTypeSelectionAlertDelegate, currentSelectedOptionValue: ListTypeValue) -> FlowContributors {
    let alert = ListTypeSelectionAlert(dependencies: ListTypeSelectionAlert.Dependencies(
      selectionDelegate: selectionDelegate,
      selectedOptionValue: currentSelectedOptionValue
    ))
    rootViewController.present(alert.alertController, animated: true, completion: nil)
    return .none
  }
  
  func summonChangeAmountOfResultsAlert(selectionDelegate: AmountOfResultsSelectionAlertDelegate, currentSelectedOptionValue: AmountOfResultsValue) -> FlowContributors {
    let alert = AmountOfNearbyResultsSelectionAlert(dependencies: AmountOfNearbyResultsSelectionAlert.Dependencies(
      selectionDelegate: selectionDelegate,
      selectedOptionValue: currentSelectedOptionValue
    ))
    rootViewController.present(alert.alertController, animated: true, completion: nil)
    return .none
  }
  
  func summonChangeSortingOrientationAlert(selectionDelegate: SortingOrientationSelectionAlertDelegate, currentSelectedOptionValue: SortingOrientationValue) -> FlowContributors {
    let alert = SortingOrientationSelectionAlert(dependencies: SortingOrientationSelectionAlert.Dependencies(
      selectionDelegate: selectionDelegate,
      selectedOptionValue: currentSelectedOptionValue
    ))
    rootViewController.present(alert.alertController, animated: true, completion: nil)
    return .none
  }
  
  func dismissChildFlow() -> FlowContributors {
    rootViewController.presentedViewController?.dismiss(animated: true, completion: nil)
    return .none
  }
}
