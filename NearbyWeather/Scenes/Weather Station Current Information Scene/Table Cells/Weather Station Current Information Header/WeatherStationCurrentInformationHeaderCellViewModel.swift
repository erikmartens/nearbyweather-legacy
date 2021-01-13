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
    let weatherInformationIdentity: PersistencyModelIdentityProtocol
    let isBookmark: Bool
    let weatherInformationService: WeatherInformationReading
    let preferencesService: UnitSettingsPreferenceReading
  }
}

// MARK: - Class Definition

final class WeatherStationCurrentInformationHeaderCellViewModel: NSObject, BaseCellViewModel { // swiftlint:disable:this type_length_violation
  
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
    let weatherInformationModelObservable = dependencies.weatherInformationService
      .createGetWeatherInformationItemObservable(
        for: dependencies.weatherInformationIdentity.identifier,
        isBookmark: dependencies.isBookmark
      )
      .map { $0.entity }
      
    return Observable
      .combineLatest(
        weatherInformationModelObservable,
        dependencies.preferencesService.createGetTemperatureUnitOptionObservable(),
        dependencies.preferencesService.createGetDimensionalUnitsOptionObservable(),
        resultSelector: { [dependencies] weatherInformationModel, temperatureUnitOption, dimensionalUnitsOption -> WeatherStationCurrentInformationHeaderCellModel in
          WeatherStationCurrentInformationHeaderCellModel(
            weatherInformationDTO: weatherInformationModel,
            temperatureUnitOption: temperatureUnitOption,
            dimensionalUnitsOption: dimensionalUnitsOption,
            isBookmark: dependencies.isBookmark
          )
        }
      )
      .asDriver(onErrorJustReturn: WeatherStationCurrentInformationHeaderCellModel())
  }
}
