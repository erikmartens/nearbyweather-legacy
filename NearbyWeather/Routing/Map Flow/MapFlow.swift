//
//  MapFlow.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxFlow
import Swinject

// MARK: - Dependencies

extension MapFlow {
  struct Dependencies {
    let dependencyContainer: Container
  }
}

// MARK: - Class Definition

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
    guard let step = transform(step: step) as? MapStep else {
      return .none
    }
    switch step {
    case .map:
      return summonWeatherMapController()
    case let .weatherDetails2(identity):
      return summonWeatherDetailsController2(identity: identity)
    case let .changeMapTypeAlert(currentSelectedOptionValue):
      return summonChangeMapTypeAlert(currentSelectedOptionValue: currentSelectedOptionValue)
    case let .changeAmountOfResultsAlert(currentSelectedOptionValue):
      return summonChangeAmountOfResultsAlert(currentSelectedOptionValue: currentSelectedOptionValue)
    case .focusOnLocationAlert:
      return .none // will be handled via `func adapt(step:)`
    case let .focusOnLocationAlertAdapted(selectionDelegate, weatherInformationDTOs):
      return summonFocusOnLocationAlert(selectionDelegate: selectionDelegate, bookmarkedLocations: weatherInformationDTOs)
    case .dismissChildFlow:
      return dismissChildFlow()
    }
  }
  
  func adapt(step: Step) -> Single<Step> {
    if let step = step as? MapStep {
      switch step {
      case let .focusOnLocationAlert(selectionDelegate):
        return Observable
          .combineLatest(
            Observable.just(selectionDelegate),
            dependencies.dependencyContainer.resolve(WeatherInformationService2.self)!
              .createGetBookmarkedWeatherInformationListObservable()
              .map { $0.map { $0.entity } },
            resultSelector: MapStep.focusOnLocationAlertAdapted
          )
          .take(1)
          .asSingle()
      default:
        return .just(step)
      }
    }
    return .just(step)
  }
  
  private func transform(step: Step) -> Step? {
    if let weatherDetailStep = step as? WeatherDetailStep {
      switch weatherDetailStep {
      case .weatherDetails:
        return nil
      case .dismiss:
        return MapStep.dismissChildFlow
      }
    }
    return step
  }
}

// MARK: - Summoning Functions

private extension MapFlow {
  
  func summonWeatherMapController() -> FlowContributors {
    let weatherMapViewController = WeatherMapViewController(dependencies: WeatherMapViewController.ViewModel.Dependencies(
      weatherInformationService: dependencies.dependencyContainer.resolve(WeatherInformationService2.self)!,
      weatherStationService: dependencies.dependencyContainer.resolve(WeatherStationService2.self)!,
      userLocationService: dependencies.dependencyContainer.resolve(UserLocationService2.self)!,
      preferencesService: dependencies.dependencyContainer.resolve(PreferencesService2.self)!,
      apiKeyService: dependencies.dependencyContainer.resolve(ApiKeyService2.self)!
    ))
    rootViewController.setViewControllers([weatherMapViewController], animated: false)
    return .one(flowContributor: .contribute(
      withNextPresentable: weatherMapViewController,
      withNextStepper: weatherMapViewController.viewModel,
      allowStepWhenNotPresented: true
    ))
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
  
  func summonChangeMapTypeAlert(currentSelectedOptionValue: MapTypeValue) -> FlowContributors { // TODO: test cancel action works properly
    let preferencesService = dependencies.dependencyContainer.resolve(PreferencesService2.self)!
    
    let alertController = MapTypeSelectionAlertController(dependencies: MapTypeSelectionAlertViewModel.Dependencies(
      selectedOptionValue: currentSelectedOptionValue,
      preferencesService: preferencesService
    ))
    rootViewController.present(alertController, animated: true, completion: nil)
    return .one(flowContributor: .contribute(withNextPresentable: alertController, withNextStepper: alertController.viewModel))
  }
  
  func summonChangeAmountOfResultsAlert(currentSelectedOptionValue: AmountOfResultsValue) -> FlowContributors {
    let preferencesService = dependencies.dependencyContainer.resolve(PreferencesService2.self)!
    
    let alertController = AmountOfNearbyResultsSelectionAlertController(dependencies: AmountOfNearbyResultsSelectionAlertViewModel.Dependencies(
      selectedOptionValue: currentSelectedOptionValue,
      preferencesService: preferencesService
    ))
    rootViewController.present(alertController, animated: true, completion: nil)
    return .one(flowContributor: .contribute(withNextPresentable: alertController, withNextStepper: alertController.viewModel))
  }
  
  func summonFocusOnLocationAlert(selectionDelegate: FocusOnLocationSelectionAlertDelegate, bookmarkedLocations: [WeatherInformationDTO]) -> FlowContributors {
    let alertController = FocusOnLocationSelectionAlertController(dependencies: FocusOnLocationSelectionAlertViewModel.Dependencies(
      bookmarkedLocations: bookmarkedLocations,
      selectionDelegate: selectionDelegate
    ))
    rootViewController.present(alertController, animated: true, completion: nil)
    return .one(flowContributor: .contribute(withNextPresentable: alertController, withNextStepper: alertController.viewModel))
  }
  
  func dismissChildFlow() -> FlowContributors {
    rootViewController.presentedViewController?.dismiss(animated: true, completion: nil)
    return .none
  }
}
