//
//  WeatherStationCurrentInformationHeaderCellViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 13.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa

// MARK: - Dependencies

extension WeatherStationCurrentInformationHeaderCellViewModel {
  struct Dependencies {
    let weatherInformationDTO: WeatherInformationDTO
    let temperatureUnitOption: TemperatureUnitOption
    let dimensionalUnitsOption: DimensionalUnitsOption
    let isBookmark: Bool
  }
}

// MARK: - Class Definition

final class WeatherStationCurrentInformationHeaderCellViewModel: NSObject, BaseCellViewModel {
  
  // MARK: - Public Access
  
  // MARK: - Properties
  
  private let dependencies: Dependencies

  // MARK: - Events
  
  let cellModelDriver: Driver<WeatherStationCurrentInformationHeaderCellModel>

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

private extension WeatherStationCurrentInformationHeaderCellViewModel {
  
  static func createDataSourceObserver(with dependencies: Dependencies) -> Driver<WeatherStationCurrentInformationHeaderCellModel> {
    Observable
      .just(
        WeatherStationCurrentInformationHeaderCellModel(
          weatherInformationDTO: dependencies.weatherInformationDTO,
          temperatureUnitOption: dependencies.temperatureUnitOption,
          dimensionalUnitsOption: dependencies.dimensionalUnitsOption,
          isBookmark: dependencies.isBookmark
        )
      )
      .asDriver(onErrorJustReturn: WeatherStationCurrentInformationHeaderCellModel())
  }
}
