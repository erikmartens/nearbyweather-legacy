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

enum ListStep: Step { // TODO: rename to WeatherListStep
  case list
  case emptyList
  case weatherDetails2(identity: PersistencyModelIdentity)
  case changeListTypeAlert(selectionDelegate: ListTypeSelectionAlertDelegate)
  case changeListTypeAlertAdapted(selectionDelegate: ListTypeSelectionAlertDelegate, currentSelectedOptionValue: ListTypeOptionValue)
  case changeAmountOfResultsAlert(selectionDelegate: AmountOfResultsSelectionAlertDelegate)
  case changeAmountOfResultsAlertAdapted(selectionDelegate: AmountOfResultsSelectionAlertDelegate, currentSelectedOptionValue: AmountOfResultsOptionValue)
  case changeSortingOrientationAlert(selectionDelegate: SortingOrientationSelectionAlertDelegate)
  case changeSortingOrientationAlertAdapted(selectionDelegate: SortingOrientationSelectionAlertDelegate, currentSelectedOptionValue: SortingOrientationOptionValue)
  case dismissChildFlow
}

final class ListStepper: Stepper { // TODO: rename to WeatherListStepper
  
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
      .resolve(WeatherInformationService2.self)?
      .createDidUpdateWeatherInformationObservable()
      .subscribe { [weak steps] informationAvailable in
        steps?.accept(
          (informationAvailable == .available) ? ListStep.list : ListStep.emptyList
        )
      }
      .disposed(by: disposeBag)
  }
}
