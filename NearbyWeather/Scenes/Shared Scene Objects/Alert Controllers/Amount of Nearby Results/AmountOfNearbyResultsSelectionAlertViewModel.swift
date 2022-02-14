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

// MARK: - Delegate

protocol AmountOfResultsSelectionAlertDelegate: class {
  func didSelectAmountOfResultsOption(_ selectedOption: AmountOfResultsOption)
}

// MARK: - Dependencies

extension AmountOfNearbyResultsSelectionAlertViewModel {
  struct Dependencies {
    weak var selectionDelegate: AmountOfResultsSelectionAlertDelegate?
    let selectedOptionValue: AmountOfResultsValue
  }
}

// MARK: - Class Definition

final class AmountOfNearbyResultsSelectionAlertViewModel: NSObject, Stepper, BaseViewModel {
  
  // MARK: - Routing
  
  let steps = PublishRelay<Step>()
  
  // MARK: - Properties
  
  let dependencies: Dependencies
  
  // MARK: - Events
  
  let onDidSelectOptionSubject = PublishSubject<AmountOfResultsOption>()
  
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
  
  func observeEvents() {
    observeDataSource()
    observeUserTapEvents()
  }
}

// MARK: - Observations

extension AmountOfNearbyResultsSelectionAlertViewModel {
  
  func observeUserTapEvents() {
    _ = onDidSelectOptionSubject
      .take(1)
      .asSingle()
      .subscribe(onSuccess: dependencies.selectionDelegate?.didSelectAmountOfResultsOption)
  }
}
