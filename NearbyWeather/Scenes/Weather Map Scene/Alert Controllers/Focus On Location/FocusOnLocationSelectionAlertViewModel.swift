//
//  FocusOnLocationSelectionAlertViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa
import RxFlow

// MARK: - Dependencies

extension FocusOnLocationSelectionAlertViewModel {
  struct Dependencies {
    let bookmarkedLocations: [WeatherInformationDTO]
    weak var selectionDelegate: FocusOnLocationSelectionAlertDelegate?
  }
}

// MARK: - Class Definition

final class FocusOnLocationSelectionAlertViewModel: NSObject, Stepper, BaseViewModel {
  
  // MARK: - Public Access
  
  var bookmarkedLocations: [WeatherInformationDTO] {
    dependencies.bookmarkedLocations
  }
  
  // MARK: - Routing
  
  let steps = PublishRelay<Step>()
  
  // MARK: - Properties
  
  let dependencies: Dependencies
  
  // MARK: - Events
  
  let onDidSelectOptionSubject = PublishSubject<FocusOnLocationOption>()
  
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

extension FocusOnLocationSelectionAlertViewModel {
  
  func observeUserTapEvents() {
    _ = onDidSelectOptionSubject
      .asObservable()
      .take(1)
      .asSingle()
      .subscribe(onSuccess: { [weak steps, dependencies] focusOnLocationOption in
        dependencies.selectionDelegate?.didSelectFocusOnLocationOption(focusOnLocationOption)
        steps?.accept(MapStep.dismissChildFlow)
      })
  }
}
