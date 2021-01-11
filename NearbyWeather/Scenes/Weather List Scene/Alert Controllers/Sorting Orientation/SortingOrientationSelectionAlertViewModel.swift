//
//  SortingOrientationSelectionViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa
import RxFlow

// MARK: - Dependencies

extension SortingOrientationSelectionAlertViewModel {
  struct Dependencies {
    let selectedOptionValue: SortingOrientationValue
    let preferencesService: WeatherListPreferenceSetting
  }
}

// MARK: - Class Definition

final class SortingOrientationSelectionAlertViewModel: NSObject, Stepper, BaseViewModel {
  
  // MARK: - Routing
  
  let steps = PublishRelay<Step>()
  
  // MARK: - Properties
  
  let dependencies: Dependencies
  
  // MARK: - Events
  
  let onDidSelectOptionSubject = PublishSubject<SortingOrientationOption>()
  
  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }
  
  // MARK: - Functions
  
  func observeEvents() {
    observeDataSource()
    observeUserTapEvents()
  }
}

// MARK: - Observations

extension SortingOrientationSelectionAlertViewModel {
  
  func observeUserTapEvents() {
    _ = onDidSelectOptionSubject
      .asSingle()
      .flatMapCompletable { [dependencies] sortingOrientationOption -> Completable in
        dependencies.preferencesService.createSetSortingOrientationOptionCompletable(sortingOrientationOption)
      }
      .subscribe { [weak steps] _ in steps?.accept(ListStep.dismissChildFlow) }
  }
}
