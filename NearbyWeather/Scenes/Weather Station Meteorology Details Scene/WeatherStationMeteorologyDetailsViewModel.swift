//
//  WeatherStationCurrentInformationViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 12.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa
import RxFlow
import CoreLocation

// MARK: - Dependencies

extension WeatherStationMeteorologyDetailsViewModel {
  struct Dependencies {
    let weatherInformationIdentity: PersistencyModelIdentity
    let weatherStationService: WeatherStationBookmarkReading
    let weatherInformationService: WeatherInformationReading
    let preferencesService: WeatherMapPreferenceReading
    let userLocationService: UserLocationReading
  }
}

// MARK: - Class Definition

final class WeatherStationMeteorologyDetailsViewModel: NSObject, Stepper, BaseViewModel {
  
  // MARK: - Routing
  
  let steps = PublishRelay<Step>()
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  var tableDelegate: WeatherStationMeteorologyDetailsTableViewDelegate? // swiftlint:disable:this weak_delegate
  let tableDataSource: WeatherStationMeteorologyDetailsTableViewDataSource
  
  // MARK: - Events
  
  // MARK: - Drivers
  
  lazy var navigationBarDriver: Driver<(String?, UIColor?, UIColor?)> = Observable
    .combineLatest(
      weatherInformationDtoObservable.map { $0.entity },
      weatherStationIsBookmarkedObservable,
      resultSelector: { (weatherInformationDTO, isBookmark) -> (String?, UIColor?, UIColor?) in
        let isDayTime = MeteorologyInformationConversionWorker.isDayTime(for: weatherInformationDTO.dayTimeInformation, coordinates: weatherInformationDTO.coordinates) ?? true
        
        let navigationBarTintColor = isBookmark
          ? isDayTime ? Constants.Theme.Color.MarqueColors.bookmarkDay : Constants.Theme.Color.MarqueColors.bookmarkNight
          : isDayTime ? Constants.Theme.Color.MarqueColors.nearbyDay : Constants.Theme.Color.MarqueColors.nearbyNight
        
        let navigationTintColor = isBookmark
          ? Constants.Theme.Color.ViewElement.titleLight
          : Constants.Theme.Color.ViewElement.titleDark
        
        return (weatherInformationDTO.stationName, navigationBarTintColor, navigationTintColor)
      }
    )
    .asDriver(onErrorJustReturn: (nil, nil, nil))
  
  // MARK: - Observables
  
  private lazy var weatherInformationDtoObservable: Observable<PersistencyModelThreadSafe<WeatherInformationDTO>> = Self.createGetWeatherInformationDtoObservable(with: dependencies).share(replay: 1)
  private lazy var weatherStationIsBookmarkedObservable: Observable<Bool> = Self.createGetWeatherStationIsBookmarkedObservable(with: dependencies).share(replay: 1)
  private lazy var temperatureUnitOptionObservable: Observable<TemperatureUnitOption> = dependencies.preferencesService.createGetTemperatureUnitOptionObservable().share(replay: 1)
  private lazy var dimensionalUnitsOptionObservable: Observable<DimensionalUnitOption> = dependencies.preferencesService.createGetDimensionalUnitsOptionObservable().share(replay: 1)
  
  // MARK: - Initialization
  
  required init(dependencies: Dependencies) {
    self.dependencies = dependencies
    tableDataSource = WeatherStationMeteorologyDetailsTableViewDataSource()
    super.init()
    
    tableDelegate = WeatherStationMeteorologyDetailsTableViewDelegate(cellSelectionDelegate: self)
  }
  
  deinit {
    printDebugMessage(
      domain: String(describing: self),
      message: "was deinitialized",
      type: .info
    )
  }

  // MARK: - Functions
  
  func observeEvents() {
    observeDataSource()
    observeUserTapEvents()
  }
}

// MARK: - Observations

extension WeatherStationMeteorologyDetailsViewModel {

  func observeDataSource() {
    let weatherStationCurrentInformationHeaderSectionItemsObservable = Observable
      .combineLatest(
        weatherInformationDtoObservable.map { $0.entity },
        temperatureUnitOptionObservable,
        dimensionalUnitsOptionObservable,
        weatherStationIsBookmarkedObservable,
        resultSelector: { weatherInformationDTO, temperatureUnitOption, dimensionalUnitsOption, isBookmark -> BaseCellViewModelProtocol in
          WeatherStationMeteorologyDetailsHeaderCellViewModel(dependencies: WeatherStationMeteorologyDetailsHeaderCellViewModel.Dependencies(
            weatherInformationDTO: weatherInformationDTO,
            temperatureUnitOption: temperatureUnitOption,
            dimensionalUnitsOption: dimensionalUnitsOption,
            isBookmark: isBookmark
          ))
        }
      )
      .map { headerCell -> [TableViewSectionDataProtocol] in
        [WeatherStationMeteorologyDetailsHeaderItemsSection(sectionItems: [headerCell])]
      }
    
    let weatherStationCurrentInformationSunCycleSectionItemsObservable = weatherInformationDtoObservable // swiftlint:disable:this identifier_name
      .map { $0.entity }
      .map { weatherInformationDTO -> [BaseCellViewModelProtocol] in
        guard let dayCycleStrings = MeteorologyInformationConversionWorker.dayCycleTimeStrings(for: weatherInformationDTO.dayTimeInformation, coordinates: weatherInformationDTO.coordinates) else {
          return []
        }
        return [WeatherStationMeteorologyDetailsSunCycleCellViewModel(dependencies: WeatherStationMeteorologyDetailsSunCycleCellViewModel.Dependencies(
          sunriseTimeString: dayCycleStrings.sunriseTimeString,
          sunsetTimeString: dayCycleStrings.sunsetTimeString
        ))]
      }
      .map { sunCycleCellItems -> [TableViewSectionDataProtocol] in
        [WeatherStationMeteorologyDetailsHeaderItemsSection(sectionItems: sunCycleCellItems)]
      }
    
    let weatherStationCurrentInformationAtmosphericDetailsSectionItemsObservable = weatherInformationDtoObservable // swiftlint:disable:this identifier_name
      .map { $0.entity }
      .map { weatherInformationDTO -> [BaseCellViewModelProtocol] in
        guard let cloudCoverage = weatherInformationDTO.cloudCoverage.coverage,
              let humidity = weatherInformationDTO.atmosphericInformation.humidity,
              let pressurePsi =  weatherInformationDTO.atmosphericInformation.pressurePsi else {
          return []
        }
        
        return [WeatherStationMeteorologyDetailsAtmosphericDetailsCellViewModel(dependencies: WeatherStationMeteorologyDetailsAtmosphericDetailsCellViewModel.Dependencies(
          cloudCoverage: cloudCoverage,
          humidity: humidity,
          pressurePsi: pressurePsi
        ))]
      }
      .map { atmosphericDetailsCellItems -> [TableViewSectionDataProtocol] in
        [WeatherStationMeteorologyDetailsAtmosphericDetailsItemsSection(sectionItems: atmosphericDetailsCellItems)]
      }
    
    let weatherStationCurrentInformationWindSectionItemsObservable = Observable
      .combineLatest(
        weatherInformationDtoObservable.map { $0.entity },
        dimensionalUnitsOptionObservable,
        resultSelector: { weatherInformationDTO, dimensionalUnitsOption -> [BaseCellViewModelProtocol] in
          guard let windspeed = weatherInformationDTO.windInformation.windspeed,
                let windDirectionDegrees = weatherInformationDTO.windInformation.degrees else {
            return []
          }
          return [WeatherStationMeteorologyDetailsWindCellViewModel(dependencies: WeatherStationMeteorologyDetailsWindCellViewModel.Dependencies(
            windSpeed: windspeed,
            windDirectionDegrees: windDirectionDegrees,
            dimensionaUnitsPreference: dimensionalUnitsOption
          ))]
        }
      )
      .map { windCellItems -> [TableViewSectionDataProtocol] in
        [WeatherStationMeteorologyDetailsWindItemsSection(sectionItems: windCellItems)]
      }
    
    let weatherStationCurrentInformationMapSectionItemsObservable = weatherInformationDtoObservable
      .map { [dependencies] weatherInformationPersistencyModel -> [BaseCellViewModelProtocol] in
        guard weatherInformationPersistencyModel.entity.coordinates.latitude != nil,
              weatherInformationPersistencyModel.entity.coordinates.longitude != nil else {
          return []
        }
        return [WeatherStationMeteorologyDetailsMapCellViewModel(dependencies: WeatherStationMeteorologyDetailsMapCellViewModel.Dependencies(
          weatherInformationIdentity: weatherInformationPersistencyModel.identity,
          weatherStationService: dependencies.weatherStationService,
          weatherInformationService: dependencies.weatherInformationService,
          preferencesService: dependencies.preferencesService,
          userLocationService: dependencies.userLocationService
        ))]
      }
      .map { mapCellItems -> [TableViewSectionDataProtocol] in
        [WeatherStationMeteorologyDetailsMapItemsSection(sectionItems: mapCellItems)]
      }
      
    Observable
      .combineLatest(
        weatherStationCurrentInformationHeaderSectionItemsObservable,
        weatherStationCurrentInformationSunCycleSectionItemsObservable,
        weatherStationCurrentInformationAtmosphericDetailsSectionItemsObservable,
        weatherStationCurrentInformationWindSectionItemsObservable,
        weatherStationCurrentInformationMapSectionItemsObservable,
        resultSelector: { headerSectionItems, sunCycleSectionItems, atmosphericDetailsSectionItems, windSectionItems, mapSectionItems -> [TableViewSectionDataProtocol] in
          headerSectionItems + sunCycleSectionItems + atmosphericDetailsSectionItems + windSectionItems + mapSectionItems
        }
      )
      .bind { [weak tableDataSource] in tableDataSource?.sectionDataSources.accept($0) }
      .disposed(by: disposeBag)
  }
}

// MARK: - Observation Helpers

private extension WeatherStationMeteorologyDetailsViewModel {
  
  static func createGetWeatherInformationDtoObservable(with dependencies: Dependencies) -> Observable<PersistencyModelThreadSafe<WeatherInformationDTO>> {
    Observable
      .combineLatest(
        Observable.just(dependencies.weatherInformationIdentity.identifier),
        Self.createGetWeatherStationIsBookmarkedObservable(with: dependencies)
      )
      .flatMapLatest(dependencies.weatherInformationService.createGetWeatherInformationItemObservable)
  }
  
  static func createGetWeatherStationIsBookmarkedObservable(with dependencies: Dependencies) -> Observable<Bool> {
    dependencies.weatherStationService.createGetIsStationBookmarkedObservable(for: dependencies.weatherInformationIdentity)
  }
}

// MARK: - Delegate Extensions

extension WeatherStationMeteorologyDetailsViewModel: BaseTableViewSelectionDelegate {
  
  func didSelectRow(at indexPath: IndexPath) {
    // nothing to do - will be used in the future
  }
}
