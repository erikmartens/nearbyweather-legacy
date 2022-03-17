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
      .startWith(WeatherListStep.loadingList)
      .bind(to: steps)
      .disposed(by: disposeBag)
  }
}
