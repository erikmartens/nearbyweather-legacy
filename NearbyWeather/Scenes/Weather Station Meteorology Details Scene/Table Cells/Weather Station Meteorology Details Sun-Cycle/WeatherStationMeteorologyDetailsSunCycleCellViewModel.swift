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

extension WeatherStationMeteorologyDetailsSunCycleCellViewModel {
  struct Dependencies {
    let sunriseTimeString: String
    let sunsetTimeString: String
  }
}

// MARK: - Class Definition

final class WeatherStationMeteorologyDetailsSunCycleCellViewModel: NSObject, BaseCellViewModel { // swiftlint:disable:this type_name
  
  // MARK: - Properties
  
  private let dependencies: Dependencies

  // MARK: - Events
  
  lazy var cellModelDriver: Driver<WeatherStationMeteorologyDetailsSunCycleCellModel> = { [dependencies] in
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

private extension WeatherStationMeteorologyDetailsSunCycleCellViewModel {
  
  static func createCellModelDriver(with dependencies: Dependencies) -> Driver<WeatherStationMeteorologyDetailsSunCycleCellModel> {
    Observable
      .just(
        WeatherStationMeteorologyDetailsSunCycleCellModel(
          sunriseTimeString: dependencies.sunriseTimeString,
          sunsetTimeString: dependencies.sunsetTimeString
        )
      )
      .asDriver(onErrorJustReturn: WeatherStationMeteorologyDetailsSunCycleCellModel())
  }
}
