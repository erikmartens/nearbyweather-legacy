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

extension SortingOrientationSelectionViewModel {
  struct Dependencies {
    let selectedOptionValue: SortingOrientationValue
    let preferencesService: PreferencesService2
  }
}

final class SortingOrientationSelectionViewModel: NSObject, Stepper, BaseViewModel {
  
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
  
  public func observeEvents() {
    observeUserTapEvents()
  }
}

// MARK: - Observations

private extension SortingOrientationSelectionViewModel {
  
  func observeUserTapEvents() {
    _ = onDidSelectOptionSubject
      .asSingle()
      .flatMapCompletable { [dependencies] sortingOrientationOption -> Completable in
        dependencies.preferencesService.setSortingOrientationOption(sortingOrientationOption)
      }
      .subscribe { [weak steps] _ in steps?.accept(ListStep.dismissChildFlow) }
  }
}
