//
//  ListFlow.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxFlow
import Swinject

// MARK: - Dependencies

extension WeatherListFlow {
  struct Dependencies {
    let dependencyContainer: Container
  }
}

// MARK: - Class Definition

final class WeatherListFlow: Flow {
  
  // MARK: - Assets
  
  var root: Presentable {
    rootViewController
  }
  
  private lazy var rootViewController = Factory.NavigationController.make(fromType: .standardTabbed(
    tabTitle: R.string.localizable.tab_weatherList(),
    tabImage: R.image.tabbar_list_ios11()
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
    guard let step = transform(step: step) as? WeatherListStep else {
      return .none
    }
    switch step {
    case .list:
      return summonWeatherListController()
    case .emptyList:
      return summonEmptyWeatherListController()
    case .loadingList:
      return summonLoadingListController()
    case let .weatherDetails(identity):
      return summonWeatherDetailsController(identity: identity)
    case .changeListTypeAlert:
      return .none // will be handled via `func adapt(step:)`
    case let .changeListTypeAlertAdapted(selectionDelegate, currentSelectedOptionValue):
      return summonChangeListTypeAlert(selectionDelegate: selectionDelegate, currentSelectedOptionValue: currentSelectedOptionValue)
    case .changeAmountOfResultsAlert:
      return .none // will be handled via `func adapt(step:)`
    case let .changeAmountOfResultsAlertAdapted(selectionDelegate, currentSelectedOptionValue):
      return summonChangeAmountOfResultsAlert(selectionDelegate: selectionDelegate, currentSelectedOptionValue: currentSelectedOptionValue)
    case .changeSortingOrientationAlert:
      return .none // will be handled via `func adapt(step:)`
    case let .changeSortingOrientationAlertAdapted(selectionDelegate, currentSelectedOptionValue):
      return summonChangeSortingOrientationAlert(selectionDelegate: selectionDelegate, currentSelectedOptionValue: currentSelectedOptionValue)
    case .dismiss:
      return dismissPresentedViewController()
    case .pop:
      return popPushedViewController()
    }
  }
  
  func adapt(step: Step) -> Single<Step> {
    guard let step = step as? WeatherListStep else {
      return .just(step)
    }
    switch step {
    case let .changeListTypeAlert(selectionDelegate):
      return Observable
        .combineLatest(
          Observable.just(selectionDelegate),
          dependencies.dependencyContainer.resolve(PreferencesService.self)!.createGetListTypeOptionObservable().map { $0.value }.take(1),
          resultSelector: WeatherListStep.changeListTypeAlertAdapted
        )
        .take(1)
        .asSingle()
    case let .changeAmountOfResultsAlert(selectionDelegate):
      return Observable
        .combineLatest(
          Observable.just(selectionDelegate),
          dependencies.dependencyContainer.resolve(PreferencesService.self)!.createGetAmountOfNearbyResultsOptionObservable().map { $0.value }.take(1),
          resultSelector: WeatherListStep.changeAmountOfResultsAlertAdapted
        )
        .take(1)
        .asSingle()
    case let .changeSortingOrientationAlert(selectionDelegate):
      return Observable
        .combineLatest(
          Observable.just(selectionDelegate),
          dependencies.dependencyContainer.resolve(PreferencesService.self)!.createGetSortingOrientationOptionObservable().map { $0.value }.take(1),
          resultSelector: WeatherListStep.changeSortingOrientationAlertAdapted
        )
        .take(1)
        .asSingle()
    default:
      return .just(step)
    }
  }
  
  private func transform(step: Step) -> Step? {
    if let weatherDetailStep = step as? WeatherStationMeteorologyDetailsStep {
      switch weatherDetailStep {
      case .weatherStationMeteorologyDetails:
        return nil
      case .end:
        return WeatherListStep.dismiss
      }
    }
    return step
  }
}

// MARK: - Summoning Functions

private extension WeatherListFlow {
  
  func summonWeatherListController() -> FlowContributors {
    let weatherListViewController = WeatherListViewController(dependencies: WeatherListViewController.ViewModel.Dependencies(
      weatherInformationService: dependencies.dependencyContainer.resolve(WeatherInformationService.self)!,
      weatherStationService: dependencies.dependencyContainer.resolve(WeatherStationService.self)!,
      userLocationService: dependencies.dependencyContainer.resolve(UserLocationService.self)!,
      preferencesService: dependencies.dependencyContainer.resolve(PreferencesService.self)!,
      apiKeyService: dependencies.dependencyContainer.resolve(ApiKeyService.self)!
    ))
    rootViewController.setViewControllers([weatherListViewController], animated: false)
    return .one(flowContributor: .contribute(
      withNextPresentable: weatherListViewController,
      withNextStepper: weatherListViewController.viewModel,
      allowStepWhenNotPresented: true
    ))
  }
  
  func summonEmptyWeatherListController() -> FlowContributors {
    let listErrorViewController = WeatherListErrorViewController(dependencies: WeatherListErrorViewController.ViewModel.Dependencies(
      apiKeyService: dependencies.dependencyContainer.resolve(ApiKeyService.self)!,
      weatherInformationService: dependencies.dependencyContainer.resolve(WeatherInformationService.self)!,
      networkReachabilityService: dependencies.dependencyContainer.resolve(NetworkReachabilityService.self)!
    ))
    rootViewController.setViewControllers([listErrorViewController], animated: false)
    return .none
  }
  
  func summonLoadingListController() -> FlowContributors {
    let loadingViewController = LoadingViewController(dependencies: LoadingViewController.ViewModel.Dependencies(title: R.string.localizable.tab_weatherList()))
    rootViewController.setViewControllers([loadingViewController], animated: false)
    return .none
  }
  
  func summonWeatherDetailsController(identity: PersistencyModelIdentity) -> FlowContributors {
    let weatherDetailFlow = WeatherStationMeteorologyDetailsFlow(dependencies: WeatherStationMeteorologyDetailsFlow.Dependencies(
      flowPresentationStyle: .pushed(navigationController: rootViewController),
      endingStep: WeatherListStep.pop,
      weatherInformationIdentity: identity,
      dependencyContainer: dependencies.dependencyContainer
    ))
    let weatherDetailStepper = WeatherStationMeteorologyDetailsStepper()
    
    return .one(flowContributor: .contribute(withNextPresentable: weatherDetailFlow, withNextStepper: weatherDetailStepper))
  }
  
  func summonChangeListTypeAlert(selectionDelegate: ListTypeSelectionAlertDelegate, currentSelectedOptionValue: ListTypeOptionValue) -> FlowContributors {
    let alert = ListTypeSelectionAlert(dependencies: ListTypeSelectionAlert.Dependencies(
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
  
  func summonChangeSortingOrientationAlert(selectionDelegate: SortingOrientationSelectionAlertDelegate, currentSelectedOptionValue: SortingOrientationOptionValue) -> FlowContributors {
    let alert = SortingOrientationSelectionAlert(dependencies: SortingOrientationSelectionAlert.Dependencies(
      selectionDelegate: selectionDelegate,
      selectedOptionValue: currentSelectedOptionValue
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
