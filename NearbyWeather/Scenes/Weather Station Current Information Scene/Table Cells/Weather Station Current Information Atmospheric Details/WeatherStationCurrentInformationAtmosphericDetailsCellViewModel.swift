//
//  WeatherStationCurrentInformationAtmosphericDetailsCellViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 15.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa

// MARK: - Dependencies

extension WeatherStationCurrentInformationAtmosphericDetailsCellViewModel {
  struct Dependencies {
    let cloudCoverage: Double
    let humidity: Double
    let pressurePsi: Double
  }
}

// MARK: - Class Definition

final class WeatherStationCurrentInformationAtmosphericDetailsCellViewModel: NSObject, BaseCellViewModel { // swiftlint:disable:this type_name
  
  // MARK: - Public Access
  
  // MARK: - Properties
  
  private let dependencies: Dependencies

  // MARK: - Events
  
  let cellModelDriver: Driver<WeatherStationCurrentInformationAtmosphericDetailsCellModel>

  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
    cellModelDriver = Self.createDataSourceObserver(with: dependencies)
  }
  
  // MARK: - Functions
  
  func observeEvents() {
    observeDataSource()
    observeUserTapEvents()
  }
}

// MARK: - Observations

private extension WeatherStationCurrentInformationAtmosphericDetailsCellViewModel {
  
  static func createDataSourceObserver(with dependencies: Dependencies) -> Driver<WeatherStationCurrentInformationAtmosphericDetailsCellModel> {
    Observable
      .just(
        WeatherStationCurrentInformationAtmosphericDetailsCellModel(
          cloudCoverage: dependencies.cloudCoverage,
          humidity: dependencies.humidity,
          pressurePsi: dependencies.pressurePsi
        )
      )
      .asDriver(onErrorJustReturn: WeatherStationCurrentInformationAtmosphericDetailsCellModel())
  }
}
