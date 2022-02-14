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

// MARK: - Delegate

protocol MapTypeSelectionAlertDelegate: class {
  func didSelectMapTypeOption(_ selectedOption: MapTypeOption)
}

// MARK: - Dependencies

extension MapTypeSelectionAlertViewModel {
  struct Dependencies {
    weak var selectionDelegate: MapTypeSelectionAlertDelegate?
    let selectedOptionValue: MapTypeValue
  }
}

// MARK: - Class Definition

final class MapTypeSelectionAlertViewModel: NSObject, BaseViewModel {
  
  // MARK: - Properties
  
  let dependencies: Dependencies
  
  // MARK: - Events
  
  let onDidSelectOptionSubject = PublishSubject<MapTypeOption>()
  
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

extension MapTypeSelectionAlertViewModel {
  
  func observeUserTapEvents() {
    _ = onDidSelectOptionSubject
      .take(1)
      .asSingle()
      .subscribe(onSuccess: dependencies.selectionDelegate?.didSelectMapTypeOption)
  }
}
