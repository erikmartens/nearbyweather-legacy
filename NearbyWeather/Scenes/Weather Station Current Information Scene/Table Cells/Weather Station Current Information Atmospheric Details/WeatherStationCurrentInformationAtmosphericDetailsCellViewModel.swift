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
  
  // MARK: - Properties
  
  private let dependencies: Dependencies

  // MARK: - Events
  
  lazy var cellModelDriver: Driver<WeatherStationCurrentInformationAtmosphericDetailsCellModel> = { [dependencies] in
    Self.createCellModelDriver(with: dependencies)
  }()

  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }
  
  // MARK: - Functions
  
  func observeEvents() {
    observeDataSource()
    observeUserTapEvents()
  }
}

// MARK: - Observation Helpers

private extension WeatherStationCurrentInformationAtmosphericDetailsCellViewModel {
  
  static func createCellModelDriver(with dependencies: Dependencies) -> Driver<WeatherStationCurrentInformationAtmosphericDetailsCellModel> {
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
