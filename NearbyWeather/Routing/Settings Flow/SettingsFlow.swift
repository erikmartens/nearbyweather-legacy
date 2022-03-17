//
//  SettingsFlow.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxFlow
import Swinject

// MARK: - Dependencies

extension SettingsFlow {
  struct Dependencies {
    let dependencyContainer: Container
  }
}

// MARK: - Definitions {

private extension SettingsFlow {
  struct Definitions {
    static let preferredTableViewStyle = UITableView.Style.insetGrouped
  }
}

// MARK: - Class Definition

final class SettingsFlow: Flow {
  
  // MARK: - Assets
  
  var root: Presentable {
    rootViewController
  }
  
  private lazy var rootViewController = Factory.NavigationController.make(fromType: .standardTabbed(
    tabTitle: R.string.localizable.tab_settings(),
    tabImage: R.image.tabbar_settings_ios11()
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
    guard let step = step as? SettingsStep else {
      return .none
    }
    switch step {
    case .settings:
      return summonSettingsController()
    case .about:
      return summonAboutAppFlow()
    case .apiKeyEdit:
      return summonApiKeyEditFlow()
    case .manageBookmarks:
      return summonManageBookmarksFlow()
    case .addBookmark:
      return summonAddBookmarkFlow()
    case .changePreferredBookmarkAlert:
      return .none // will be handled via `func adapt(step:)`
    case let .changePreferredBookmarkAlertAdapted(selectionDelegate, selectedOptionValue, boomarkedLocations):
      return summonChangePreferredBookmarkAlert(selectionDelegate: selectionDelegate, preferredBookmarkOption: selectedOptionValue, bookmarkedLocations: boomarkedLocations)
    case .changeTemperatureUnitAlert:
      return .none // will be handled via `func adapt(step:)`
    case let .changeTemperatureUnitAlertAdapted(selectionDelegate, currentSelectedOptionValue):
      return summonChangeTemperatureUnitAlert(selectionDelegate: selectionDelegate, currentSelectedOptionValue: currentSelectedOptionValue)
    case .changeDimensionalUnitAlert:
      return .none // will be handled via `func adapt(step:)`
    case let .changeDimensionalUnitAlertAdapted(selectionDelegate, selectedOptionValue):
      return summonChangeDimensionalUnitAlert(selectionDelegate: selectionDelegate, currentSelectedOptionValue: selectedOptionValue)
    case let .webBrowser(url):
      return summonWebBrowser(url: url)
    case .pop:
      return popPushedViewController()
    }
  }
  
  func adapt(step: Step) -> Single<Step> {
    guard let step = step as? SettingsStep else {
      return .just(step)
    }
    switch step {
    case let .changePreferredBookmarkAlert(selectionDelegate):
      return Observable
        .combineLatest(
          Observable.just(selectionDelegate),
          dependencies.dependencyContainer.resolve(WeatherStationService.self)!.createGetPreferredBookmarkObservable(),
          dependencies.dependencyContainer.resolve(WeatherStationService.self)!.createGetBookmarkedStationsObservable().take(1),
          resultSelector: SettingsStep.changePreferredBookmarkAlertAdapted
        )
        .take(1)
        .asSingle()
    case let .changeTemperatureUnitAlert(selectionDelegate):
      return Observable
        .combineLatest(
          Observable.just(selectionDelegate),
          dependencies.dependencyContainer.resolve(PreferencesService.self)!.createGetTemperatureUnitOptionObservable().map { $0.value }.take(1),
          resultSelector: SettingsStep.changeTemperatureUnitAlertAdapted
        )
        .take(1)
        .asSingle()
    case let .changeDimensionalUnitAlert(selectionDelegate):
      return Observable
        .combineLatest(
          Observable.just(selectionDelegate),
          dependencies.dependencyContainer.resolve(PreferencesService.self)!.createGetDimensionalUnitsOptionObservable().map { $0.value }.take(1),
          resultSelector: SettingsStep.changeDimensionalUnitAlertAdapted
        )
        .take(1)
        .asSingle()
    default:
      return .just(step)
    }
  }
}

// MARK: - Summoning Functions

private extension SettingsFlow {
  
  func summonSettingsController() -> FlowContributors {
    let settingsViewController = SettingsViewController(dependencies: SettingsViewModel.Dependencies(
      weatherStationService: dependencies.dependencyContainer.resolve(WeatherStationService.self)!,
      preferencesService: dependencies.dependencyContainer.resolve(PreferencesService.self)!,
      notificationService: dependencies.dependencyContainer.resolve(NotificationService.self)!
    ))
    rootViewController.setViewControllers([settingsViewController], animated: false)
    return .one(flowContributor: .contribute(
      withNextPresentable: settingsViewController,
      withNextStepper: settingsViewController.viewModel,
      allowStepWhenNotPresented: true
    ))
  }
  
  func summonAboutAppFlow() -> FlowContributors {
    let aboutAppFlow = AboutAppFlow(dependencies: AboutAppFlow.Dependencies(
      flowPresentationStyle: .pushed(navigationController: rootViewController),
      endingStep: SettingsStep.pop,
      dependencyContainer: dependencies.dependencyContainer
    ))
    let aboutAppStepper = AboutAppStepper()

    return .one(flowContributor: .contribute(withNextPresentable: aboutAppFlow, withNextStepper: aboutAppStepper))
  }
  
  func summonApiKeyEditFlow() -> FlowContributors {
    let apiKeyInputFlow = ApiKeyInputFlow(dependencies: ApiKeyInputFlow.Dependencies(
      flowPresentationStyle: .pushed(navigationController: rootViewController),
      endingStep: SettingsStep.pop,
      dependencyContainer: dependencies.dependencyContainer
    ))
    let apiKeyInputStepper = ApiKeyInputStepper()
    
    return .one(flowContributor: .contribute(withNextPresentable: apiKeyInputFlow, withNextStepper: apiKeyInputStepper))
  }
  
  func summonManageBookmarksFlow() -> FlowContributors {
    let manageBookmarksFlow = ManageBookmarksFlow(dependencies: ManageBookmarksFlow.Dependencies(
      flowPresentationStyle: .pushed(navigationController: rootViewController),
      endingStep: SettingsStep.pop,
      dependencyContainer: dependencies.dependencyContainer
    ))
    let manageBookmarksStepper = ManageBookmarksStepper()
    
    return .one(flowContributor: .contribute(withNextPresentable: manageBookmarksFlow, withNextStepper: manageBookmarksStepper))
  }
  
  func summonAddBookmarkFlow() -> FlowContributors {
    let addBookmarkFlow = AddBookmarkFlow(dependencies: AddBookmarkFlow.Dependencies(
      flowPresentationStyle: .pushed(navigationController: rootViewController),
      endingStep: SettingsStep.pop,
      dependencyContainer: dependencies.dependencyContainer
    ))
    let addBookmarkStepper = AddBookmarkStepper()
    
    return .one(flowContributor: .contribute(withNextPresentable: addBookmarkFlow, withNextStepper: addBookmarkStepper))
  }
  
  func summonChangePreferredBookmarkAlert(selectionDelegate: PreferredBookmarkSelectionAlertDelegate, preferredBookmarkOption: PreferredBookmarkOption?, bookmarkedLocations: [WeatherStationDTO]) -> FlowContributors {
    let alert = PreferredBookmarkSelectionAlert(dependencies: PreferredBookmarkSelectionAlert.Dependencies(
      preferredBookmarkOption: preferredBookmarkOption,
      bookmarkedLocations: bookmarkedLocations,
      selectionDelegate: selectionDelegate
    ))
    rootViewController.present(alert.alertController, animated: true, completion: nil)
    return .none
  }
  
  func summonChangeTemperatureUnitAlert(selectionDelegate: TemperatureUnitSelectionAlertDelegate, currentSelectedOptionValue: TemperatureUnitOptionValue) -> FlowContributors {
    let alert = TemperatureUnitSelectionAlert(dependencies: TemperatureUnitSelectionAlert.Dependencies(
      selectionDelegate: selectionDelegate,
      selectedOptionValue: currentSelectedOptionValue
    ))
    rootViewController.present(alert.alertController, animated: true, completion: nil)
    return .none
  }
  
  func summonChangeDimensionalUnitAlert(selectionDelegate: DimensionalUnitSelectionAlertDelegate, currentSelectedOptionValue: DimensionalUnitOptionValue) -> FlowContributors {
    let alert = DimensionalUnitSelectionAlert(dependencies: DimensionalUnitSelectionAlert.Dependencies(
      selectionDelegate: selectionDelegate,
      selectedOptionValue: currentSelectedOptionValue
    ))
    rootViewController.present(alert.alertController, animated: true, completion: nil)
    return .none
  }
  
  func summonWebBrowser(url: URL) -> FlowContributors {
    rootViewController.presentSafariViewController(for: url)
    return .none
  }
  
  func popPushedViewController() -> FlowContributors {
    rootViewController.popViewController(animated: true)
    return .none
  }
}
