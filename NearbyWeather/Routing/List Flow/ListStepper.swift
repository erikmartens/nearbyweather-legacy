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

enum ListStep: Step {
  case list
  case emptyList
  case weatherDetails2(identity: PersistencyModelIdentity)
  case changeListTypeAlert(selectionDelegate: ListTypeSelectionAlertDelegate, currentSelectedOptionValue: ListTypeValue)
  case changeAmountOfResultsAlert(selectionDelegate: AmountOfResultsSelectionAlertDelegate, currentSelectedOptionValue: AmountOfResultsValue)
  case changeSortingOrientationAlert(selectionDelegate: SortingOrientationSelectionAlertDelegate, currentSelectedOptionValue: SortingOrientationValue)
  case dismissChildFlow
}

final class ListStepper: Stepper {
  
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
