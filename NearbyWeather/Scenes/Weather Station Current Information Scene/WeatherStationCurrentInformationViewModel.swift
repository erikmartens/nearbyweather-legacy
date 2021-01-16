//
//  WeatherStationCurrentInformationViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 12.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa
import RxFlow
import CoreLocation

// MARK: - Dependencies

extension WeatherStationCurrentInformationViewModel {
  struct Dependencies {
    let weatherInformationIdentity: PersistencyModelIdentityProtocol
    let isBookmark: Bool
    let weatherInformationService: WeatherInformationReading
    let preferencesService: WeatherMapPreferenceReading
  }
}

// MARK: - Class Definition

final class WeatherStationCurrentInformationViewModel: NSObject, Stepper, BaseViewModel {
  
  // MARK: - Routing
  
  let steps = PublishRelay<Step>()
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  var tableDelegate: WeatherStationCurrentInformationTableViewDelegate? // swiftlint:disable:this weak_delegate
  let tableDataSource: WeatherStationCurrentInformationTableViewDataSource
  
  // MARK: - Events
  
  // MARK: - Drivers
  
  // MARK: - Observables
  
  // MARK: - Initialization
  
  required init(dependencies: Dependencies) {
    self.dependencies = dependencies
    tableDataSource = WeatherStationCurrentInformationTableViewDataSource()
    super.init()
    
    tableDelegate = WeatherStationCurrentInformationTableViewDelegate(cellSelectionDelegate: self)
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

extension WeatherStationCurrentInformationViewModel {

  func observeDataSource() {
    
  }
  
  func observeUserTapEvents() {
    
  }
}

// MARK: - Delegate Extensions

extension WeatherStationCurrentInformationViewModel: BaseTableViewSelectionDelegate {
  
  func didSelectRow(at indexPath: IndexPath) {
    
  }
}
