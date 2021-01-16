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

extension WeatherStationCurrentInformationWindCellViewModel {
  struct Dependencies {
    let windSpeed: Double
    let windDirectionDegrees: Double
    let dimensionaUnitsPreference: DimensionalUnitsOption
  }
}

// MARK: - Class Definition

final class WeatherStationCurrentInformationWindCellViewModel: NSObject, BaseCellViewModel {
  
  // MARK: - Properties
  
  private let dependencies: Dependencies

  // MARK: - Events
  
  lazy var cellModelDriver: Driver<WeatherStationCurrentInformationWindCellModel> = { [dependencies] in
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

private extension WeatherStationCurrentInformationWindCellViewModel {
  
  static func createCellModelDriver(with dependencies: Dependencies) -> Driver<WeatherStationCurrentInformationWindCellModel> {
    Observable
      .just(
        WeatherStationCurrentInformationWindCellModel(
          windSpeed: dependencies.windSpeed,
          windDirectionDegrees: dependencies.windDirectionDegrees,
          dimensionaUnitsPreference: dependencies.dimensionaUnitsPreference
        )
      )
      .asDriver(onErrorJustReturn: WeatherStationCurrentInformationWindCellModel())
  }
}
