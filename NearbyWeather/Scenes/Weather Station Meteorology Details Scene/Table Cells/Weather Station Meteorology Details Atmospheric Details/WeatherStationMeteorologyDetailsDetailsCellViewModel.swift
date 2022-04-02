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

extension WeatherStationMeteorologyDetailsAtmosphericDetailsCellViewModel {
  struct Dependencies {
    let cloudCoverage: Double
    let humidity: Double
    let pressurePsi: Double
  }
}

// MARK: - Class Definition

final class WeatherStationMeteorologyDetailsAtmosphericDetailsCellViewModel: NSObject, BaseCellViewModel { // swiftlint:disable:this type_name
  
  let associatedCellReuseIdentifier = WeatherStationMeteorologyDetailsAtmosphericDetailsCell.reuseIdentifier
  
  // MARK: - Properties
  
  private let dependencies: Dependencies

  // MARK: - Events
  
  lazy var cellModelDriver: Driver<WeatherStationMeteorologyDetailsAtmosphericDetailsCellModel> = { [dependencies] in
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

private extension WeatherStationMeteorologyDetailsAtmosphericDetailsCellViewModel {
  
  static func createCellModelDriver(with dependencies: Dependencies) -> Driver<WeatherStationMeteorologyDetailsAtmosphericDetailsCellModel> {
    Observable
      .just(
        WeatherStationMeteorologyDetailsAtmosphericDetailsCellModel(
          cloudCoverage: dependencies.cloudCoverage,
          humidity: dependencies.humidity,
          pressurePsi: dependencies.pressurePsi
        )
      )
      .asDriver(onErrorJustReturn: WeatherStationMeteorologyDetailsAtmosphericDetailsCellModel())
  }
}
