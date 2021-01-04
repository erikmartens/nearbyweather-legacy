//
//  ListWeatherInformationTableCellViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa

extension WeatherListTableViewCellViewModel {
  
  struct Dependencies {
    let weatherInformationIdentity: PersistencyModelIdentityProtocol
    let isBookmark: Bool
    let weatherInformationService: WeatherInformationService2
    let preferencesService: PreferencesService2
  }
}

final class WeatherListTableViewCellViewModel: NSObject, BaseCellViewModel {
  
  // MARK: - Public Access
  
  var weatherInformationIdentity: PersistencyModelIdentityProtocol {
    dependencies.weatherInformationIdentity
  }
  
  // MARK: - Properties
  
  private let dependencies: Dependencies

  // MARK: - Events
  
  let cellModelDriver: Driver<WeatherListTableViewCellModel>

  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
    cellModelDriver = Self.createDataSourceObserver(with: dependencies)
  }
}

// MARK: - Observations

private extension WeatherListTableViewCellViewModel {
  
  static func createDataSourceObserver(with dependencies: Dependencies) -> Driver<WeatherListTableViewCellModel> {
    let weatherInformationModelObservable = Observable
      .just(dependencies.isBookmark)
      .flatMapLatest { [dependencies] isBookmark -> Observable<PersistencyModel<WeatherInformationDTO>?> in
        isBookmark
          ? dependencies.weatherInformationService.createBookmarkedWeatherInformationObservable(for: dependencies.weatherInformationIdentity.identifier)
          : dependencies.weatherInformationService.createNearbyWeatherInformationObservable(for: dependencies.weatherInformationIdentity.identifier)
      }
      .map { $0?.entity }
      
    return Observable
      .combineLatest(
        weatherInformationModelObservable.errorOnNil(),
        dependencies.preferencesService.createTemperatureUnitOptionObservable(),
        dependencies.preferencesService.createDimensionalUnitsOptionObservable(),
        resultSelector: { weatherInformationModel, temperatureUnitOption, dimensionalUnitsOption -> WeatherListTableViewCellModel in
          WeatherListTableViewCellModel(
            weatherConditionSymbol: ConversionWorker.weatherConditionSymbol(
              fromWeatherCode: weatherInformationModel.weatherCondition.first?.identifier,
              isDayTime: ConversionWorker.isDayTime(for: weatherInformationModel.daytimeInformation, coordinates: weatherInformationModel.coordinates)
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
            backgroundColor: .clear // TODO
            // TODO border
          )
        }
      )
      .asDriver(onErrorJustReturn: WeatherListTableViewCellModel())
  }
}
