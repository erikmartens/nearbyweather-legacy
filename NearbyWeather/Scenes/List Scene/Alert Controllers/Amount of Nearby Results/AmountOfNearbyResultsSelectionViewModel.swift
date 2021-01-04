//
//  AmountOfNearbyResultsSelectionViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa
import RxFlow

extension AmountOfNearbyResultsSelectionViewModel {
  struct Dependencies {
    let preferencesService: PreferencesService2
  }
}

final class AmountOfNearbyResultsSelectionViewModel: NSObject, Stepper, BaseViewModel {
  
  // MARK: - Routing
  
  let steps = PublishRelay<Step>()
  
  // MARK: - Properties
  
  let dependencies: Dependencies
  
  // MARK: - Events
  
  let onDidSelectAmountOfResultsSubject = PublishSubject<AmountOfResultsOption>()
  
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

private extension AmountOfNearbyResultsSelectionViewModel {
  
  func observeUserTapEvents() {
    _ = onDidSelectAmountOfResultsSubject
      .asSingle()
      .flatMapCompletable { [dependencies] amountOfResultsOption -> Completable in
        dependencies.preferencesService.setAmountOfNearbyResultsOption(amountOfResultsOption)
      }
      .subscribe { [weak steps] _ in steps?.accept(ListStep.dismissChildFlow) }
  }
}
