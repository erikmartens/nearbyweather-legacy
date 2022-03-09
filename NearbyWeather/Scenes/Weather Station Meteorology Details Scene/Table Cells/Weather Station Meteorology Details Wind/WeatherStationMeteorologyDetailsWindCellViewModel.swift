//
//  WeatherStationCurrentInformationWindCellViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 15.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa

// MARK: - Dependencies

extension WeatherStationMeteorologyDetailsWindCellViewModel {
  struct Dependencies {
    let windSpeed: Double
    let windDirectionDegrees: Double
    let dimensionaUnitsPreference: DimensionalUnitOption
  }
}

// MARK: - Class Definition

final class WeatherStationMeteorologyDetailsWindCellViewModel: NSObject, BaseCellViewModel {
  
  // MARK: - Properties
  
  private let dependencies: Dependencies

  // MARK: - Events
  
  lazy var cellModelDriver: Driver<WeatherStationMeteorologyDetailsWindCellModel> = { [dependencies] in
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

private extension WeatherStationMeteorologyDetailsWindCellViewModel {
  
  static func createCellModelDriver(with dependencies: Dependencies) -> Driver<WeatherStationMeteorologyDetailsWindCellModel> {
    Observable
      .just(
        WeatherStationMeteorologyDetailsWindCellModel(
          windSpeed: dependencies.windSpeed,
          windDirectionDegrees: dependencies.windDirectionDegrees,
          dimensionaUnitsPreference: dependencies.dimensionaUnitsPreference
        )
      )
      .asDriver(onErrorJustReturn: WeatherStationMeteorologyDetailsWindCellModel())
  }
}
