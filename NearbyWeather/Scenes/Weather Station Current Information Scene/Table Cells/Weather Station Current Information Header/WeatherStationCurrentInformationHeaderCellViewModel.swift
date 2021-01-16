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

final class WeatherStationCurrentInformationHeaderCellViewModel: NSObject, BaseCellViewModel { // swiftlint:disable:this type_name
  
  // MARK: - Properties
  
  private let dependencies: Dependencies

  // MARK: - Events
  
  lazy var cellModelDriver: Driver<WeatherStationCurrentInformationHeaderCellModel> = { [dependencies] in
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

private extension WeatherStationCurrentInformationHeaderCellViewModel {
  
  static func createCellModelDriver(with dependencies: Dependencies) -> Driver<WeatherStationCurrentInformationHeaderCellModel> {
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
