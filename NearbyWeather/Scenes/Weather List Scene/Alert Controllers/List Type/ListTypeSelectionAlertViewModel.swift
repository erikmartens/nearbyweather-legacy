//
//  ListTypeSelectionViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa
import RxFlow

// MARK: - Delegate

protocol ListTypeSelectionAlertDelegate: class {
  func didSelectListTypeOption(_ selectedOption: ListTypeOption)
}

// MARK: - Dependencies

extension ListTypeSelectionAlertViewModel {
  struct Dependencies {
    weak var selectionDelegate: ListTypeSelectionAlertDelegate?
    let selectedOptionValue: ListTypeValue
  }
}

// MARK: - Class Definition

final class ListTypeSelectionAlertViewModel: NSObject, Stepper, BaseViewModel {
  
  // MARK: - Routing
  
  let steps = PublishRelay<Step>()
  
  // MARK: - Properties
  
  let dependencies: Dependencies
  
  // MARK: - Events
  
  let onDidSelectOptionSubject = PublishSubject<ListTypeOption>()
  
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

extension ListTypeSelectionAlertViewModel {
  
  func observeUserTapEvents() {
    _ = onDidSelectOptionSubject
      .take(1)
      .asSingle()
      .subscribe(onSuccess: dependencies.selectionDelegate?.didSelectListTypeOption)
  }
}
