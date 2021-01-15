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
  
  let cellModelDriver: Driver<WeatherStationCurrentInformationWindCellModel>

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

private extension WeatherStationCurrentInformationWindCellViewModel {
  
  static func createDataSourceObserver(with dependencies: Dependencies) -> Driver<WeatherStationCurrentInformationWindCellModel> {
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
