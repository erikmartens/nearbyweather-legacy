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
    
    self.cellModelDriver = Self.createDataSourceObserver(with: dependencies)
  }
}

// MARK: - Observations

private extension WeatherListTableViewCellViewModel {
  
  static func createDataSourceObserver(with dependencies: Dependencies) -> Driver<WeatherListTableViewCellModel> {
    Observable.just(dependencies.isBookmark)
      .flatMapLatest { [dependencies] isBookmark -> Observable<PersistencyModel<WeatherInformationDTO>?> in
        if isBookmark {
          return dependencies.weatherInformationService
            .createBookmarkedWeatherInformationObservable(for: dependencies.weatherInformationIdentity.identifier)
        }
        return dependencies.weatherInformationService
          .createNearbyWeatherInformationObservable(for: dependencies.weatherInformationIdentity.identifier)
      }
      .map { $0?.entity }
      .errorOnNil()
      .map { weatherInformation -> WeatherListTableViewCellModel in
        WeatherListTableViewCellModel(
          weatherConditionSymbol: ConversionWorker.weatherConditionSymbol(
            fromWeatherCode: weatherInformation.weatherCondition.first?.identifier,
            isDayTime: ConversionWorker.isDayTime(for: weatherInformation.daytimeInformation, coordinates: weatherInformation.coordinates)
          ),
          temperature: ConversionWorker.temperatureDescriptor(
            forTemperatureUnit: PreferencesService.shared.temperatureUnit, // TODO observe user preference service 2
            fromRawTemperature: weatherInformation.atmosphericInformation.temperatureKelvin
          ),
          cloudCoverage: weatherInformation.cloudCoverage.coverage?.append(contentsOf: "%", delimiter: .none),
          humidity: weatherInformation.atmosphericInformation.humidity?.append(contentsOf: "%", delimiter: .none),
          windspeed: ConversionWorker.windspeedDescriptor(
            forDistanceSpeedUnit: PreferencesService.shared.distanceSpeedUnit, // TODO observe user preference service 2
            forWindspeed: weatherInformation.windInformation.windspeed
          ),
          backgroundColor: .clear // TODO
          // TODO border
        )
      }
      .asDriver(onErrorJustReturn: WeatherListTableViewCellModel())
  }
}
