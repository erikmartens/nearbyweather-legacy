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
          let isDayTime = ConversionWorker.isDayTime(for: weatherInformationModel.daytimeInformation, coordinates: weatherInformationModel.coordinates) ?? true
          
          return WeatherListInformationTableViewCellModel(
            weatherConditionSymbol: ConversionWorker.weatherConditionSymbol(
              fromWeatherCode: weatherInformationModel.weatherCondition.first?.identifier,
              isDayTime: isDayTime
            ),
            temperature: ConversionWorker.temperatureDescriptor(
              forTemperatureUnit: temperatureUnitOption,
              fromRawTemperature: weatherInformationModel.atmosphericInformation.temperatureKelvin
            ),
            cloudCoverage: weatherInformationModel.cloudCoverage.coverage?.append(contentsOf: "%", delimiter: .none),
            humidity: weatherInformationModel.atmosphericInformation.humidity?.append(contentsOf: "%", delimiter: .none),
            windspeed: ConversionWorker.windspeedDescriptor(
              forDistanceSpeedUnit: dimensionalUnitsOption,
              forWindspeed: weatherInformationModel.windInformation.windspeed
            ),
            backgroundColor: Self.backgroundColor(for: dependencies.isBookmark, isDayTime: isDayTime),
            borderColor: Self.borderColor(for: dependencies.isBookmark)
          )
        }
      )
      .asDriver(onErrorJustReturn: WeatherListInformationTableViewCellModel())
  }
}

// MARK: - Helpers

private extension WeatherListInformationTableViewCellViewModel {
  
  static func borderColor(for isBookmark: Bool) -> UIColor {
    isBookmark
      ? Constants.Theme.Color.ViewElement.borderBookmark
      : Constants.Theme.Color.ViewElement.borderNearby
  }
  
  static func backgroundColor(for isBookmark: Bool, isDayTime: Bool) -> UIColor {
    isBookmark
      ? (isDayTime ? Constants.Theme.Color.MarqueColors.bookmarkDay : Constants.Theme.Color.MarqueColors.bookmarkNight)
      : (isDayTime ? Constants.Theme.Color.MarqueColors.nearbyDay : Constants.Theme.Color.MarqueColors.nearbyNight)
  }
}
