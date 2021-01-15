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
    let cloudCoverageDTO: WeatherInformationDTO.CloudCoverageDTO
    let atmosphericInformationDTO: WeatherInformationDTO.AtmosphericInformationDTO
  }
}

// MARK: - Class Definition

final class WeatherStationCurrentInformationAtmosphericDetailsCellViewModel: NSObject, BaseCellViewModel {
  
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
          cloudCoverageDTO: dependencies.cloudCoverageDTO,
          atmosphericInformationDTO: dependencies.atmosphericInformationDTO
        )
      )
      .asDriver(onErrorJustReturn: WeatherStationCurrentInformationAtmosphericDetailsCellModel())
  }
}
