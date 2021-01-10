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
  
  let onDidTapAnnotationView = PublishSubject<Void>()
  
  // MARK: - Drivers
  
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
        resultSelector: { [dependencies] weatherInformationModel, temperatureUnitOption -> WeatherMapAnnotationModel in
          WeatherMapAnnotationModel(
            weatherInformationDTO: weatherInformationModel,
            temperatureUnitOption: temperatureUnitOption,
            isBookmark: dependencies.isBookmark
          )
        }
      )
      .asDriver(onErrorJustReturn: WeatherMapAnnotationModel())
  }
}
