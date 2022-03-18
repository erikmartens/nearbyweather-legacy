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

extension WeatherMapFlow {
  struct Dependencies {
    let dependencyContainer: Container
  }
}

// MARK: - Class Definition

final class WeatherMapFlow: Flow {
  
  // MARK: - Assets
  
  var root: Presentable {
    rootViewController
  }
  
  private lazy var rootViewController = Factory.NavigationController.make(fromType: .standardTabbed(
    tabTitle: R.string.localizable.tab_weatherMap(),
    tabImage: R.image.tabbar_map_ios11()
  ))
  
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
  
  func navigate(to step: Step) -> FlowContributors { // swiftlint:disable:this cyclomatic_complexity
    guard let step = transform(step: step) as? WeatherMapStep else {
      return .none
    }
    switch step {
    case .map:
      return summonWeatherMapController()
    case let .weatherDetails2(identity):
      return summonWeatherDetailsController2(identity: identity)
    case .changeMapTypeAlert:
      return .none // will be handled via `func adapt(step:)`
    case let .changeMapTypeAlertAdapted(selectionDelegate, currentSelectedOptionValue):
      return summonChangeMapTypeAlert(selectionDelegate: selectionDelegate, currentSelectedOptionValue: currentSelectedOptionValue)
    case .changeAmountOfResultsAlert:
      return .none // will be handled via `func adapt(step:)`
    case let .changeAmountOfResultsAlertAdapted(selectionDelegate, currentSelectedOptionValue):
      return summonChangeAmountOfResultsAlert(selectionDelegate: selectionDelegate, currentSelectedOptionValue: currentSelectedOptionValue)
    case .focusOnLocationAlert:
      return .none // will be handled via `func adapt(step:)`
    case let .focusOnLocationAlertAdapted(selectionDelegate, weatherStationDTOs):
      return summonFocusOnLocationAlert(selectionDelegate: selectionDelegate, bookmarkedLocations: weatherStationDTOs)
    case .dismiss:
      return dismissPresentedViewController()
    case .pop:
      return popPushedViewController()
    }
  }
  
  func adapt(step: Step) -> Single<Step> {
    guard let step = step as? WeatherMapStep else {
      return .just(step)
    }
    switch step {
    case let .changeMapTypeAlert(selectionDelegate):
      return Observable
        .combineLatest(
          Observable.just(selectionDelegate),
          dependencies.dependencyContainer.resolve(PreferencesService.self)!.createGetMapTypeOptionObservable().map { $0.value }.take(1),
          resultSelector: WeatherMapStep.changeMapTypeAlertAdapted
        )
        .take(1)
        .asSingle()
    case let .changeAmountOfResultsAlert(selectionDelegate):
      return Observable
        .combineLatest(
          Observable.just(selectionDelegate),
          dependencies.dependencyContainer.resolve(PreferencesService.self)!.createGetAmountOfNearbyResultsOptionObservable().map { $0.value }.take(1),
          resultSelector: WeatherMapStep.changeAmountOfResultsAlertAdapted
        )
        .take(1)
        .asSingle()
    case let .focusOnLocationAlert(selectionDelegate):
      return Observable
        .combineLatest(
          Observable.just(selectionDelegate),
          dependencies.dependencyContainer.resolve(WeatherStationService.self)!.createGetBookmarkedStationsObservable().take(1),
          resultSelector: WeatherMapStep.focusOnLocationAlertAdapted
        )
        .take(1)
        .asSingle()
    default:
      return .just(step)
    }
  }
  
  private func transform(step: Step) -> Step? {
    guard let weatherDetailStep = step as? WeatherStationMeteorologyDetailsStep else {
      return step
    }
    switch weatherDetailStep {
    case .weatherStationMeteorologyDetails:
      return nil
    case .end:
      return WeatherMapStep.dismiss
    }
  }
}

// MARK: - Summoning Functions

private extension WeatherMapFlow {
  
  func summonWeatherMapController() -> FlowContributors {
    let weatherMapViewController = WeatherMapViewController(dependencies: WeatherMapViewController.ViewModel.Dependencies(
      weatherInformationService: dependencies.dependencyContainer.resolve(WeatherInformationService.self)!,
      weatherStationService: dependencies.dependencyContainer.resolve(WeatherStationService.self)!,
      userLocationService: dependencies.dependencyContainer.resolve(UserLocationService.self)!,
      preferencesService: dependencies.dependencyContainer.resolve(PreferencesService.self)!,
      apiKeyService: dependencies.dependencyContainer.resolve(ApiKeyService.self)!
    ))
    rootViewController.setViewControllers([weatherMapViewController], animated: false)
    return .one(flowContributor: .contribute(
      withNextPresentable: weatherMapViewController,
      withNextStepper: weatherMapViewController.viewModel,
      allowStepWhenNotPresented: true
    ))
  }
  
  func summonWeatherDetailsController2(identity: PersistencyModelIdentity) -> FlowContributors {
    let weatherDetailFlow = WeatherStationMeteorologyDetailsFlow(dependencies: WeatherStationMeteorologyDetailsFlow.Dependencies(
      flowPresentationStyle: .presented,
      endingStep: WeatherMapStep.dismiss,
      weatherInformationIdentity: identity,
      dependencyContainer: dependencies.dependencyContainer
    ))
    let weatherDetailStepper = WeatherStationMeteorologyDetailsStepper()
    
    Flows.use(weatherDetailFlow, when: .ready) { [unowned rootViewController] (weatherDetailRoot: UINavigationController) in
      weatherDetailRoot.viewControllers.first?.addCloseButton {
        weatherDetailStepper.steps.accept(WeatherStationMeteorologyDetailsStep.end)
      }
      rootViewController.present(weatherDetailRoot, animated: true)
    }
    
    return .one(flowContributor: .contribute(withNextPresentable: weatherDetailFlow, withNextStepper: weatherDetailStepper))
  }
  
  func summonChangeMapTypeAlert(selectionDelegate: MapTypeSelectionAlertDelegate, currentSelectedOptionValue: MapTypeOptionValue) -> FlowContributors {
    let alert = MapTypeSelectionAlert(dependencies: MapTypeSelectionAlert.Dependencies(
      selectionDelegate: selectionDelegate,
      selectedOptionValue: currentSelectedOptionValue
    ))
    
    rootViewController.present(alert.alertController, animated: true, completion: nil)
    return .none
  }
  
  func summonChangeAmountOfResultsAlert(selectionDelegate: AmountOfResultsSelectionAlertDelegate, currentSelectedOptionValue: AmountOfResultsOptionValue) -> FlowContributors {
    let alert = AmountOfNearbyResultsSelectionAlert(dependencies: AmountOfNearbyResultsSelectionAlert.Dependencies(
      selectionDelegate: selectionDelegate,
      selectedOptionValue: currentSelectedOptionValue
    ))
    rootViewController.present(alert.alertController, animated: true, completion: nil)
    return .none
  }
  
  func summonFocusOnLocationAlert(selectionDelegate: FocusOnLocationSelectionAlertDelegate, bookmarkedLocations: [WeatherStationDTO]) -> FlowContributors {
    let alert = FocusOnLocationSelectionAlert(dependencies: FocusOnLocationSelectionAlert.Dependencies(
      bookmarkedLocations: bookmarkedLocations,
      selectionDelegate: selectionDelegate
    ))
    rootViewController.present(alert.alertController, animated: true, completion: nil)
    return .none
  }
  
  func dismissPresentedViewController() -> FlowContributors {
    rootViewController.presentedViewController?.dismiss(animated: true, completion: nil)
    return .none
  }
  
  func popPushedViewController() -> FlowContributors {
    rootViewController.popViewController(animated: true)
    return .none
  }
}
