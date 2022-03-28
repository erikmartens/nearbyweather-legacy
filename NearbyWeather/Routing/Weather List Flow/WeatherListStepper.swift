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
  case changeListTypeAlertAdapted(selectionDelegate: ListTypeSelectionAlertDelegate, currentSelectedOptionValue: ListTypeOptionValue) // TODO: do not pass option value here
  case changeAmountOfResultsAlert(selectionDelegate: AmountOfResultsSelectionAlertDelegate)
  case changeAmountOfResultsAlertAdapted(selectionDelegate: AmountOfResultsSelectionAlertDelegate, currentSelectedOptionValue: AmountOfResultsOptionValue) // TODO: do not pass option value here
  case changeSortingOrientationAlert(selectionDelegate: SortingOrientationSelectionAlertDelegate)
  case changeSortingOrientationAlertAdapted(selectionDelegate: SortingOrientationSelectionAlertDelegate, currentSelectedOptionValue: SortingOrientationOptionValue) // TODO: do not pass option value here
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
    case (.changeListTypeAlert, .changeListTypeAlert), (.changeListTypeAlertAdapted, .changeListTypeAlertAdapted), (.changeAmountOfResultsAlert, .changeAmountOfResultsAlert), (.changeAmountOfResultsAlertAdapted, .changeAmountOfResultsAlertAdapted), (.changeSortingOrientationAlert, .changeSortingOrientationAlert), (.changeSortingOrientationAlertAdapted, .changeSortingOrientationAlertAdapted): // swiftlint:disable:this line_length
      return false
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
