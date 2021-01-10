//
//  WeatherMapAnnotationViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 10.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import MapKit
import RxSwift
import RxCocoa

// MARK: - Dependencies

extension WeatherMapAnnotationViewModel {
  struct Dependencies {
    let weatherInformationIdentity: PersistencyModelIdentityProtocol
    let isBookmark: Bool
    let coordinate: CLLocationCoordinate2D
    let weatherInformationService: WeatherInformationPersistence
    let preferencesService: UnitSettingsPreferenceReading
  }
}

// MARK: - Class Definition

final class WeatherMapAnnotationViewModel: NSObject, BaseAnnotationViewModel {
  
  // MARK: - Public Access
  
  var weatherInformationIdentity: PersistencyModelIdentityProtocol {
    dependencies.weatherInformationIdentity
  }
  
  var isBookmark: Bool {
    dependencies.isBookmark
  }
  
  var coordinate: CLLocationCoordinate2D {
    dependencies.coordinate
  }
  
  // MARK: - Properties
  
  private let dependencies: Dependencies

  // MARK: - Events
  
  let annotationModelDriver: Driver<WeatherMapAnnotationModel>

  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
    annotationModelDriver = Self.createDataSourceObserver(with: dependencies)
  }
}

// MARK: - Observations

private extension WeatherMapAnnotationViewModel {
  
  static func createDataSourceObserver(with dependencies: Dependencies) -> Driver<WeatherMapAnnotationModel> {
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
        resultSelector: { [dependencies] weatherInformationModel, temperatureUnitOption, dimensionalUnitsOption -> WeatherMapAnnotationModel in
          let isDayTime = ConversionWorker.isDayTime(for: weatherInformationModel.daytimeInformation, coordinates: weatherInformationModel.coordinates) ?? true
          
          return WeatherMapAnnotationModel(
            title: <#T##String?#>,
            subtitle: <#T##String?#>,
            isDayTime: isDayTime,
            borderColor: Self.borderColor(for: dependencies.isBookmark),
            backgroundColor: Self.backgroundColor(for: dependencies.isBookmark, isDayTime: isDayTime)
          )
          
//          return WeatherMapAnnotationModel(
//            weatherConditionSymbol: ConversionWorker.weatherConditionSymbol(
//              fromWeatherCode: weatherInformationModel.weatherCondition.first?.identifier,
//              isDayTime: isDayTime
//            ),
//            temperature: ConversionWorker.temperatureDescriptor(
//              forTemperatureUnit: temperatureUnitOption,
//              fromRawTemperature: weatherInformationModel.atmosphericInformation.temperatureKelvin
//            ),
//            cloudCoverage: weatherInformationModel.cloudCoverage.coverage?.append(contentsOf: "%", delimiter: .none),
//            humidity: weatherInformationModel.atmosphericInformation.humidity?.append(contentsOf: "%", delimiter: .none),
//            windspeed: ConversionWorker.windspeedDescriptor(
//              forDistanceSpeedUnit: dimensionalUnitsOption,
//              forWindspeed: weatherInformationModel.windInformation.windspeed
//            ),
//            backgroundColor: Self.backgroundColor(for: dependencies.isBookmark, isDayTime: isDayTime),
//            borderColor: Self.borderColor(for: dependencies.isBookmark)
//          )
        }
      )
      .asDriver(onErrorJustReturn: WeatherMapAnnotationModel())
  }
}

// MARK: - Helpers

private extension WeatherMapAnnotationViewModel {
  
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
