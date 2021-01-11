//
//  MapTypeSelectionAlertViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa
import RxFlow

// MARK: - Dependencies

extension MapTypeSelectionAlertViewModel {
  struct Dependencies {
    let selectedOptionValue: MapTypeValue
    let preferencesService: WeatherMapPreferenceSetting
  }
}

// MARK: - Class Definition

final class MapTypeSelectionAlertViewModel: NSObject, Stepper, BaseViewModel {
  
  // MARK: - Routing
  
  let steps = PublishRelay<Step>()
  
  // MARK: - Properties
  
  let dependencies: Dependencies
  
  // MARK: - Events
  
  let onDidSelectOptionSubject = PublishSubject<MapTypeOption>()
  
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

extension MapTypeSelectionAlertViewModel {
  
  func observeUserTapEvents() {
    _ = onDidSelectOptionSubject
      .asSingle()
      .flatMapCompletable { [dependencies] mapTypeOption -> Completable in
        dependencies.preferencesService.createSetPreferredMapTypeOptionCompletable(mapTypeOption)
      }
      .subscribe { [weak steps] _ in steps?.accept(ListStep.dismissChildFlow) }
  }
}
