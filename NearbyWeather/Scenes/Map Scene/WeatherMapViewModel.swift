//
//  WeatherMapViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 10.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa
import RxFlow
import CoreLocation

// MARK: - Dependencies

extension WeatherMapViewModel {
  struct Dependencies {
    let weatherInformationService: WeatherInformationPersistence & WeatherInformationUpdating
    let weatherStationService: WeatherStationBookmarkReading
    let userLocationService: UserLocationReading
    let preferencesService: WeatherMapPreferencePersistence & UnitSettingsPreferenceReading
    let apiKeyService: ApiKeyReading
  }
}

// MARK: - Class Definition

final class WeatherMapViewModel: NSObject, Stepper, BaseViewModel {
  
  // MARK: - Routing
  
  let steps = PublishRelay<Step>()
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  // MARK: - Events
  
  // MARK: - Observables
  
  // MARK: - Initialization
  
  required init(dependencies: Dependencies) {
    self.dependencies = dependencies
    super.init()
  }
  
  // MARK: - Functions
  
  public func observeEvents() {
    observeUserTapEvents()
    observeDataSource()
  }
}

private extension WeatherMapViewModel {
  
  func observeUserTapEvents() {
    
  }

  func observeDataSource() {
  
  }
}
