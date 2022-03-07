//
//  SettingsViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 06.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa
import RxFlow
import CoreLocation

// MARK: - Dependencies

extension SettingsViewModel {
  struct Dependencies {
  }
}

// MARK: - Class Definition

final class SettingsViewModel: NSObject, Stepper, BaseViewModel {
  
  // MARK: - Routing
  
  let steps = PublishRelay<Step>()
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  var tableDelegate: SettingsTableViewDelegate? // swiftlint:disable:this weak_delegate
  let tableDataSource: SettingsTableViewDataSource
  
  // MARK: - Events
  
  // MARK: - Drivers
  
  // MARK: - Observables
  
  // MARK: - Initialization
  
  required init(dependencies: Dependencies) {
    self.dependencies = dependencies
    tableDataSource = SettingsTableViewDataSource()
    super.init()
    
    tableDelegate = SettingsTableViewDelegate(cellSelectionDelegate: self)
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

extension SettingsViewModel {

  func observeDataSource() {
    
  }
  
  func observeUserTapEvents() {
    
  }
}

// MARK: - Delegate Extensions

extension SettingsViewModel: BaseTableViewSelectionDelegate {
  
  func didSelectRow(at indexPath: IndexPath) {
    
  }
}

// MARK: - Helpers

private extension SettingsViewModel {
  
}

// MARK: - Delegate Extensions

// MARK: - Helper Extensions
