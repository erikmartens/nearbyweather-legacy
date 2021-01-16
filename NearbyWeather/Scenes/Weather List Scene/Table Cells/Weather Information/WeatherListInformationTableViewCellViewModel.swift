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
    let weatherStationService: WeatherStationBookmarkReading
    let weatherInformationService: WeatherInformationReading
    let preferencesService: WeatherMapPreferenceReading
  }
}

// MARK: - Class Definition

final class WeatherListInformationTableViewCellViewModel: NSObject, BaseCellViewModel {
  
  // MARK: - Public Access
  
  var weatherInformationIdentity: PersistencyModelIdentityProtocol {
    dependencies.weatherInformationIdentity
  }
  
  // MARK: - Properties
  
  private let dependencies: Dependencies

  // MARK: - Events
  
  lazy var cellModelDriver: Driver<WeatherListInformationTableViewCellModel> = { [dependencies] in
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

private extension WeatherListInformationTableViewCellViewModel {
  
  static func createCellModelDriver(with dependencies: Dependencies) -> Driver<WeatherListInformationTableViewCellModel> {
    let weatherStationIsBookmarkedObservable = Self.createGetWeatherStationIsBookmarkedObservable(with: dependencies).share(replay: 1)
    
    let weatherInformationDtoObservable = Observable
      .combineLatest(
        Observable.just(dependencies.weatherInformationIdentity.identifier),
        weatherStationIsBookmarkedObservable
      )
      .flatMapLatest(dependencies.weatherInformationService.createGetWeatherInformationItemObservable)
      .map { $0.entity }
      
    return Observable
      .combineLatest(
        weatherInformationDtoObservable,
        dependencies.preferencesService.createGetTemperatureUnitOptionObservable(),
        dependencies.preferencesService.createGetDimensionalUnitsOptionObservable(),
        weatherStationIsBookmarkedObservable,
        resultSelector: { weatherInformationModel, temperatureUnitOption, dimensionalUnitsOption, isBookmark -> WeatherListInformationTableViewCellModel in
          WeatherListInformationTableViewCellModel(
            weatherInformationDTO: weatherInformationModel,
            temperatureUnitOption: temperatureUnitOption,
            dimensionalUnitsOption: dimensionalUnitsOption,
            isBookmark: isBookmark
          )
        }
      )
      .asDriver(onErrorJustReturn: WeatherListInformationTableViewCellModel())
  }
  
  static func createGetWeatherStationIsBookmarkedObservable(with dependencies: Dependencies) -> Observable<Bool> {
    dependencies.weatherStationService.createGetIsStationBookmarkedObservable(for: dependencies.weatherInformationIdentity)
  }
}
