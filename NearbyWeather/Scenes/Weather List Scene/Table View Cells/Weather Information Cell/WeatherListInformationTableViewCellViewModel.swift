//
//  ListWeatherInformationTableCellViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa
import RxFlow

// MARK: - Dependencies

extension WeatherListInformationTableViewCellViewModel {
  struct Dependencies {
    let weatherStationName: String
    let weatherInformationIdentity: PersistencyModelIdentity
    let weatherStationService: WeatherStationBookmarkReading
    let weatherInformationService: WeatherInformationReading
    let preferencesService: WeatherMapPreferenceReading
  }
}

// MARK: - Class Definition

final class WeatherListInformationTableViewCellViewModel: NSObject, BaseCellViewModel {
  
  let associatedCellReuseIdentifier = WeatherListInformationTableViewCell.reuseIdentifier
  lazy var onSelectedRoutingIntent: Step? = {
    WeatherListStep.weatherDetails(identity: dependencies.weatherInformationIdentity)
  }()
  
  // MARK: - Public Access
  
  var weatherInformationIdentity: PersistencyModelIdentity {
    dependencies.weatherInformationIdentity
  }
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  private let dependencies: Dependencies

  // MARK: - Events
  
  // MARK: - Observables
  
  private lazy var cellModelRelay: BehaviorRelay<WeatherListInformationTableViewCellModel> = Self.createCellModelRelay(with: dependencies)
  
  // MARK: - Drivers
  
  lazy var cellModelDriver: Driver<WeatherListInformationTableViewCellModel> = cellModelRelay.asDriver(onErrorJustReturn: WeatherListInformationTableViewCellModel())

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

extension WeatherListInformationTableViewCellViewModel {
  
  func observeDataSource() {
    let weatherStationIsBookmarkedObservable = dependencies.weatherStationService
      .createGetIsStationBookmarkedObservable(for: dependencies.weatherInformationIdentity)
      .share(replay: 1)
    
    let weatherInformationDtoObservable = Observable
      .combineLatest(
        Observable.just(dependencies.weatherInformationIdentity.identifier),
        weatherStationIsBookmarkedObservable
      )
      .flatMapLatest(dependencies.weatherInformationService.createGetWeatherInformationItemObservable)
      .map { $0.entity }
      
    Observable
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
      .catchAndReturn(WeatherListInformationTableViewCellModel())
      .bind(to: cellModelRelay)
      .disposed(by: disposeBag)
  }
}

// MARK: - Observation Helpers

private extension WeatherListInformationTableViewCellViewModel {
  
  static func createCellModelRelay(with dependencies: Dependencies) -> BehaviorRelay<WeatherListInformationTableViewCellModel> {
    BehaviorRelay<WeatherListInformationTableViewCellModel>(
      value: WeatherListInformationTableViewCellModel(
        weatherConditionSymbol: nil, // start with default value
        placeName: dependencies.weatherStationName,
        temperature: nil, // start with default value
        cloudCoverage: nil, // start with default value
        humidity: nil, // start with default value
        windspeed: nil, // start with default value
        backgroundColor: Constants.Theme.Color.ViewElement.WeatherInformation.colorBackgroundDay // start with default value
      )
    )
  }
}
