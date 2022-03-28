//
//  ListStepper.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa
import RxFlow
import Swinject

enum WeatherListStep: Step {
  case list
  case emptyList
  case loadingList
  case weatherDetails(identity: PersistencyModelIdentity)
  case changeListTypeAlert(selectionDelegate: ListTypeSelectionAlertDelegate)
  case changeListTypeAlertAdapted(selectionDelegate: ListTypeSelectionAlertDelegate, currentSelectedOptionValue: ListTypeOptionValue)
  case changeAmountOfResultsAlert(selectionDelegate: AmountOfResultsSelectionAlertDelegate)
  case changeAmountOfResultsAlertAdapted(selectionDelegate: AmountOfResultsSelectionAlertDelegate, currentSelectedOptionValue: AmountOfResultsOptionValue)
  case changeSortingOrientationAlert(selectionDelegate: SortingOrientationSelectionAlertDelegate)
  case changeSortingOrientationAlertAdapted(selectionDelegate: SortingOrientationSelectionAlertDelegate, currentSelectedOptionValue: SortingOrientationOptionValue)
  case dismiss
  case pop
}

extension WeatherListStep: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (let .weatherDetails(lhsIdentity), let .weatherDetails(rhsIdentity)):
      return lhsIdentity.identifier == rhsIdentity.identifier
    case (.list, .list), (.emptyList, .emptyList), (.loadingList, .loadingList), (.dismiss, .dismiss), (.pop, .pop):
      return true
    case (.changeListTypeAlert, .changeListTypeAlert), (.changeAmountOfResultsAlert, .changeAmountOfResultsAlert), (.changeSortingOrientationAlert, .changeSortingOrientationAlert):
      return false
    case (let .changeListTypeAlertAdapted(_, lhsOption), let .changeListTypeAlertAdapted(_, rhsOption)):
      return lhsOption.rawValue == rhsOption.rawValue
    case (let .changeAmountOfResultsAlertAdapted(_, lhsOption), let .changeAmountOfResultsAlertAdapted(_, rhsOption)):
      return lhsOption.rawValue == rhsOption.rawValue
    case (let .changeSortingOrientationAlertAdapted(_, lhsOption), let .changeSortingOrientationAlertAdapted(_, rhsOption)):
      return lhsOption.rawValue == rhsOption.rawValue
    default:
      return false
    }
  }
}

final class WeatherListStepper: Stepper {
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  let steps = PublishRelay<Step>()
  
  // MARK: - Properties
  
  let dependencyContainer: Container
  
  // MARK: - Initialization
  
  init(dependencyContainer: Container) {
    self.dependencyContainer = dependencyContainer
  }
  
  func readyToEmitSteps() {
    dependencyContainer
      .resolve(WeatherInformationService.self)?
      .createDidUpdateWeatherInformationObservable()
      .map { informationAvailable in (informationAvailable == .available) ? WeatherListStep.list : WeatherListStep.emptyList }
      .distinctUntilChanged { lhsStep, rhsStep in
        guard let lhsWeatherListStep = lhsStep as? WeatherListStep, let rhsWeatherListStep = rhsStep as? WeatherListStep else {
          return true
        }
        return lhsWeatherListStep == rhsWeatherListStep
      }
      .bind(to: steps)
      .disposed(by: disposeBag)
  }
}
