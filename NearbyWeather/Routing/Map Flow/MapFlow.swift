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

final class MapFlow: Flow { // TODO: rename to WeatherMapFlow
  
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
    case .changeMapTypeAlert(_):
      return .none // will be handled via `func adapt(step:)`
    case let .changeMapTypeAlertAdapted(selectionDelegate, currentSelectedOptionValue):
      return summonChangeMapTypeAlert(selectionDelegate: selectionDelegate, currentSelectedOptionValue: currentSelectedOptionValue)
    case .changeAmountOfResultsAlert(_):
      return .none // will be handled via `func adapt(step:)`
    case let .changeAmountOfResultsAlertAdapted(selectionDelegate, currentSelectedOptionValue):
      return summonChangeAmountOfResultsAlert(selectionDelegate: selectionDelegate, currentSelectedOptionValue: currentSelectedOptionValue)
    case .focusOnLocationAlert(_):
      return .none // will be handled via `func adapt(step:)`
    case let .focusOnLocationAlertAdapted(selectionDelegate, weatherInformationDTOs):
      return summonFocusOnLocationAlert(selectionDelegate: selectionDelegate, bookmarkedLocations: weatherInformationDTOs)
    case .dismissChildFlow:
      return dismissChildFlow()
    }
  }
  
  func adapt(step: Step) -> Single<Step> {
    guard let step = step as? MapStep else {
      return .just(step)
    }
    switch step {
    case let .changeMapTypeAlert(selectionDelegate):
      return Observable
        .combineLatest(
          Observable.just(selectionDelegate),
          dependencies.dependencyContainer.resolve(PreferencesService2.self)!.createGetMapTypeOptionObservable().map { $0.value }.take(1),
          resultSelector: MapStep.changeMapTypeAlertAdapted
        )
        .take(1)
        .asSingle()
    case let .changeAmountOfResultsAlert(selectionDelegate):
      return Observable
        .combineLatest(
          Observable.just(selectionDelegate),
          dependencies.dependencyContainer.resolve(PreferencesService2.self)!.createGetAmountOfNearbyResultsOptionObservable().map { $0.value }.take(1),
          resultSelector: MapStep.changeAmountOfResultsAlertAdapted
        )
        .take(1)
        .asSingle()
    case let .focusOnLocationAlert(selectionDelegate):
      return Observable
        .combineLatest(
          Observable.just(selectionDelegate),
          dependencies.dependencyContainer.resolve(WeatherInformationService2.self)!.createGetBookmarkedWeatherInformationListObservable().map { $0.map { $0.entity } }.take(1),
          resultSelector: MapStep.focusOnLocationAlertAdapted
        )
        .take(1)
        .asSingle()
    default:
      return .just(step)
    }
  }
  
  private func transform(step: Step) -> Step? {
    guard let weatherDetailStep = step as? WeatherDetailStep else {
      return step
    }
    switch weatherDetailStep {
    case .weatherDetails:
      return nil
    case .dismiss:
      return MapStep.dismissChildFlow
    }
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
  
  func summonWeatherDetailsController2(identity: PersistencyModelIdentity) -> FlowContributors {
    let weatherDetailFlow = WeatherDetailFlow(dependencies: WeatherDetailFlow.Dependencies(
      weatherInformationIdentity: identity,
      dependencyContainer: dependencies.dependencyContainer
    ))
    let weatherDetailStepper = WeatherDetailStepper()
    
    Flows.use(weatherDetailFlow, when: .ready) { [unowned rootViewController] (weatherDetailRoot: UINavigationController) in
      weatherDetailRoot.viewControllers.first?.addCloseButton {
        weatherDetailStepper.steps.accept(WeatherDetailStep.dismiss)
      }
      rootViewController.present(weatherDetailRoot, animated: true)
    }
    
    return .one(flowContributor: .contribute(withNextPresentable: weatherDetailFlow, withNextStepper: weatherDetailStepper))
  }
  
  func summonChangeMapTypeAlert(selectionDelegate: MapTypeSelectionAlertDelegate, currentSelectedOptionValue: MapTypeValue) -> FlowContributors {
    let alert = MapTypeSelectionAlert(dependencies: MapTypeSelectionAlert.Dependencies(
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
  
  func summonFocusOnLocationAlert(selectionDelegate: FocusOnLocationSelectionAlertDelegate, bookmarkedLocations: [WeatherInformationDTO]) -> FlowContributors {
    let alert = FocusOnLocationSelectionAlert(dependencies: FocusOnLocationSelectionAlert.Dependencies(
      bookmarkedLocations: bookmarkedLocations,
      selectionDelegate: selectionDelegate
    ))
    rootViewController.present(alert.alertController, animated: true, completion: nil)
    return .none
  }
  
  func dismissChildFlow() -> FlowContributors {
    rootViewController.presentedViewController?.dismiss(animated: true, completion: nil)
    return .none
  }
}
