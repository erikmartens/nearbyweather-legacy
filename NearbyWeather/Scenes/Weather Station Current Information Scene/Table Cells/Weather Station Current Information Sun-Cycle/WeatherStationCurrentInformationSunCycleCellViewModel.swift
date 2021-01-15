//
//  WeatherStationCurrentInformationSunCycleCellViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 14.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa

// MARK: - Dependencies

extension WeatherStationCurrentInformationSunCycleCellViewModel {
  struct Dependencies {
    let dayTimeInformationDTO: WeatherInformationDTO.DayTimeInformationDTO
    let coordinatesDTO: WeatherInformationDTO.CoordinatesDTO
  }
}

// MARK: - Class Definition

final class WeatherStationCurrentInformationSunCycleCellViewModel: NSObject, BaseCellViewModel {
  
  // MARK: - Public Access
  
  // MARK: - Properties
  
  private let dependencies: Dependencies

  // MARK: - Events
  
  let cellModelDriver: Driver<WeatherStationCurrentInformationSunCycleCellModel>

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

private extension WeatherStationCurrentInformationSunCycleCellViewModel {
  
  static func createDataSourceObserver(with dependencies: Dependencies) -> Driver<WeatherStationCurrentInformationSunCycleCellModel> {
    Observable
      .just(
        WeatherStationCurrentInformationSunCycleCellModel(
          dayTimeInformationDTO: dependencies.dayTimeInformationDTO,
          coordinatesDTO: dependencies.coordinatesDTO
        )
      )
      .asDriver(onErrorJustReturn: WeatherStationCurrentInformationSunCycleCellModel())
  }
}
