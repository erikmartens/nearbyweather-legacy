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

extension ListFlow {
  struct Dependencies {
    let dependencyContainer: Container
  }
}

// MARK: - Class Definition

final class ListFlow: Flow {  // TODO: rename to WeatherListFlow
  
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
    case .changeListTypeAlert(_):
      return .none // will be handled via `func adapt(step:)`
    case let .changeListTypeAlertAdapted(selectionDelegate, currentSelectedOptionValue):
      return summonChangeListTypeAlert(selectionDelegate: selectionDelegate, currentSelectedOptionValue: currentSelectedOptionValue)
    case .changeAmountOfResultsAlert(_):
      return .none // will be handled via `func adapt(step:)`
    case let .changeAmountOfResultsAlertAdapted(selectionDelegate, currentSelectedOptionValue):
      return summonChangeAmountOfResultsAlert(selectionDelegate: selectionDelegate, currentSelectedOptionValue: currentSelectedOptionValue)
    case .changeSortingOrientationAlert(_):
      return .none // will be handled via `func adapt(step:)`
    case let .changeSortingOrientationAlertAdapted(selectionDelegate, currentSelectedOptionValue):
      return summonChangeSortingOrientationAlert(selectionDelegate: selectionDelegate, currentSelectedOptionValue: currentSelectedOptionValue)
    case .dismissChildFlow:
      return dismissChildFlow()
    }
  }
  
  func adapt(step: Step) -> Single<Step> {
    guard let step = step as? ListStep else {
      return .just(step)
    }
    switch step {
    case let .changeListTypeAlert(selectionDelegate):
      return Observable
        .combineLatest(
          Observable.just(selectionDelegate),
          dependencies.dependencyContainer.resolve(PreferencesService2.self)!.createGetListTypeOptionObservable().map { $0.value }.take(1),
          resultSelector: ListStep.changeListTypeAlertAdapted
        )
        .take(1)
        .asSingle()
    case let .changeAmountOfResultsAlert(selectionDelegate):
      return Observable
        .combineLatest(
          Observable.just(selectionDelegate),
          dependencies.dependencyContainer.resolve(PreferencesService2.self)!.createGetAmountOfNearbyResultsOptionObservable().map { $0.value }.take(1),
          resultSelector: ListStep.changeAmountOfResultsAlertAdapted
        )
        .take(1)
        .asSingle()
    case let .changeSortingOrientationAlert(selectionDelegate):
      return Observable
        .combineLatest(
          Observable.just(selectionDelegate),
          dependencies.dependencyContainer.resolve(PreferencesService2.self)!.createGetSortingOrientationOptionObservable().map { $0.value }.take(1),
          resultSelector: ListStep.changeSortingOrientationAlertAdapted
        )
        .take(1)
        .asSingle()
    default:
      return .just(step)
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
    let listErrorViewController = ListErrorViewController(dependencies: ListErrorViewController.ViewModel.Dependencies(
      apiKeyService: dependencies.dependencyContainer.resolve(ApiKeyService2.self)!,
      weatherInformationService: dependencies.dependencyContainer.resolve(WeatherInformationService2.self)!,
      networkReachabilityService: dependencies.dependencyContainer.resolve(NetworkReachabilityService.self)!
    ))
    rootViewController.setViewControllers([listErrorViewController], animated: false)
    return .none
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
  
  func dismissChildFlow() -> FlowContributors {
    rootViewController.presentedViewController?.dismiss(animated: true, completion: nil)
    return .none
  }
}
