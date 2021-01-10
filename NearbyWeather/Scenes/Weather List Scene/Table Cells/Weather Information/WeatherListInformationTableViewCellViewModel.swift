//
//  ListWeatherInformationTableCellViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa

// MARK: - Dependencies

extension WeatherListInformationTableViewCellViewModel {
  struct Dependencies {
    let weatherInformationIdentity: PersistencyModelIdentityProtocol
    let isBookmark: Bool
    let weatherInformationService: WeatherInformationPersistence
    let preferencesService: UnitSettingsPreferenceReading
  }
}

// MARK: - Class Definition

final class WeatherListInformationTableViewCellViewModel: NSObject, BaseCellViewModel {
  
  // MARK: - Public Access
  
  var weatherInformationIdentity: PersistencyModelIdentityProtocol {
    dependencies.weatherInformationIdentity
  }
  
  var isBookmark: Bool {
    dependencies.isBookmark
  }
  
  // MARK: - Properties
  
  private let dependencies: Dependencies

  // MARK: - Events
  
  let cellModelDriver: Driver<WeatherListInformationTableViewCellModel>

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

private extension WeatherListInformationTableViewCellViewModel {
  
  static func createDataSourceObserver(with dependencies: Dependencies) -> Driver<WeatherListInformationTableViewCellModel> {
    let weatherInformationModelObservable = Observable
      .just(dependencies.isBookmark)
      .flatMapLatest { [dependencies] isBookmark -> Observable<PersistencyModel<WeatherInformationDTO>> in
        isBookmark
          ? dependencies.weatherInformationService.createGetBookmarkedWeatherInformationItemObservable(for: dependencies.weatherInformationIdentity.identifier)
          : dependencies.weatherInformationService.createGetNearbyWeatherInformationObservable(for: dependencies.weatherInformationIdentity.identifier)
      }
      .map { $0.entity }
      
    return Observable
      .combineLatest(
        weatherInformationModelObservable,
        dependencies.preferencesService.createGetTemperatureUnitOptionObservable(),
        dependencies.preferencesService.createGetDimensionalUnitsOptionObservable(),
        resultSelector: { [dependencies] weatherInformationModel, temperatureUnitOption, dimensionalUnitsOption -> WeatherListInformationTableViewCellModel in
          WeatherListInformationTableViewCellModel(
            weatherInformationDTO: weatherInformationModel,
            temperatureUnitOption: temperatureUnitOption,
            dimensionalUnitsOption: dimensionalUnitsOption,
            isBookmark: dependencies.isBookmark
          )
        }
      )
      .asDriver(onErrorJustReturn: WeatherListInformationTableViewCellModel())
  }
}
