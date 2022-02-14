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

// MARK: - Delegate

protocol SortingOrientationSelectionAlertDelegate: class {
  func didSortingOrientationOption(_ selectedOption: SortingOrientationOption)
}

// MARK: - Dependencies

extension SortingOrientationSelectionAlertViewModel {
  struct Dependencies {
    weak var selectionDelegate: SortingOrientationSelectionAlertDelegate?
    let selectedOptionValue: SortingOrientationValue
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

extension SortingOrientationSelectionAlertViewModel {
  
  func observeUserTapEvents() {
    _ = onDidSelectOptionSubject
      .take(1)
      .asSingle()
      .subscribe(onSuccess: dependencies.selectionDelegate?.didSortingOrientationOption)
  }
}
