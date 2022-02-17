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

extension WeatherStationCurrentInformationViewModel {
  struct Dependencies {
    let weatherInformationIdentity: PersistencyModelIdentityProtocol
    let weatherStationService: WeatherStationBookmarkReading
    let weatherInformationService: WeatherInformationReading
    let preferencesService: WeatherMapPreferenceReading
    let userLocationService: UserLocationReading
  }
}

// MARK: - Class Definition

final class WeatherStationCurrentInformationViewModel: NSObject, Stepper, BaseViewModel { // TODO: Rename everything to WeatherStationDetailedInformation
  
  // MARK: - Routing
  
  let steps = PublishRelay<Step>()
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  var tableDelegate: WeatherStationCurrentInformationTableViewDelegate? // swiftlint:disable:this weak_delegate
  let tableDataSource: WeatherStationCurrentInformationTableViewDataSource
  
  // MARK: - Events
  
  // MARK: - Drivers
  
  lazy var navigationBarColorDriver: Driver<(UIColor?, UIColor?)> = { [unowned self] in
    Observable
      .combineLatest(
        self.weatherInformationDtoObservable.map { $0.entity },
        self.weatherStationIsBookmarkedObservable,
        resultSelector: { (weatherInformationDTO, isBookmark) -> (UIColor?, UIColor?) in
          let isDayTime = ConversionWorker.isDayTime(for: weatherInformationDTO.dayTimeInformation, coordinates: weatherInformationDTO.coordinates) ?? true
          
          let navigationBarTintColor = isBookmark
            ? isDayTime ? Constants.Theme.Color.MarqueColors.bookmarkDay : Constants.Theme.Color.MarqueColors.bookmarkNight
            : isDayTime ? Constants.Theme.Color.MarqueColors.nearbyDay : Constants.Theme.Color.MarqueColors.nearbyNight
          
          let navigationTintColor = isBookmark
            ? Constants.Theme.Color.ViewElement.titleLight
            : Constants.Theme.Color.ViewElement.titleDark
          
          return (navigationBarTintColor, navigationTintColor)
        }
      )
      .asDriver(onErrorJustReturn: (nil, nil))
  }()
  
  // MARK: - Observables
  
  private lazy var weatherInformationDtoObservable: Observable<PersistencyModelThreadSafe<WeatherInformationDTO>> = { [dependencies] in
    Self.createGetWeatherInformationDtoObservable(with: dependencies).share(replay: 1)
  }()
  
  private lazy var weatherStationIsBookmarkedObservable: Observable<Bool> = { [dependencies] in
    Self.createGetWeatherStationIsBookmarkedObservable(with: dependencies).share(replay: 1)
  }()
  
  private lazy var temperatureUnitOptionObservable: Observable<TemperatureUnitOption> = { [dependencies] in
    dependencies.preferencesService.createGetTemperatureUnitOptionObservable().share(replay: 1)
  }()
  
  private lazy var dimensionalUnitsOptionObservable: Observable<DimensionalUnitsOption> = { [dependencies] in
    dependencies.preferencesService.createGetDimensionalUnitsOptionObservable().share(replay: 1)
  }()
  
  // MARK: - Initialization
  
  required init(dependencies: Dependencies) {
    self.dependencies = dependencies
    tableDataSource = WeatherStationCurrentInformationTableViewDataSource()
    super.init()
    
    tableDelegate = WeatherStationCurrentInformationTableViewDelegate(cellSelectionDelegate: self)
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

extension WeatherStationCurrentInformationViewModel {

  func observeDataSource() {
    let weatherStationCurrentInformationHeaderSectionItemsObservable = Observable
      .combineLatest(
        weatherInformationDtoObservable.map { $0.entity },
        temperatureUnitOptionObservable,
        dimensionalUnitsOptionObservable,
        weatherStationIsBookmarkedObservable,
        resultSelector: { weatherInformationDTO, temperatureUnitOption, dimensionalUnitsOption, isBookmark -> BaseCellViewModelProtocol in
          WeatherStationCurrentInformationHeaderCellViewModel(dependencies: WeatherStationCurrentInformationHeaderCellViewModel.Dependencies(
            weatherInformationDTO: weatherInformationDTO,
            temperatureUnitOption: temperatureUnitOption,
            dimensionalUnitsOption: dimensionalUnitsOption,
            isBookmark: isBookmark
          ))
        }
      )
      .map { headerCell -> [TableViewSectionData] in
        [WeatherStationCurrentInformationHeaderItemsSection(
          sectionCellsIdentifier: WeatherStationCurrentInformationHeaderCell.reuseIdentifier,
          sectionItems: [headerCell]
        )]
      }
    
    let weatherStationCurrentInformationSunCycleSectionItemsObservable = weatherInformationDtoObservable // swiftlint:disable:this identifier_name
      .map { $0.entity }
      .map { weatherInformationDTO -> [BaseCellViewModelProtocol] in
        guard let dayCycleStrings = ConversionWorker.dayCycleTimeStrings(for: weatherInformationDTO.dayTimeInformation, coordinates: weatherInformationDTO.coordinates) else {
          return []
        }
        return [WeatherStationCurrentInformationSunCycleCellViewModel(dependencies: WeatherStationCurrentInformationSunCycleCellViewModel.Dependencies(
          sunriseTimeString: dayCycleStrings.sunriseTimeString,
          sunsetTimeString: dayCycleStrings.sunsetTimeString
        ))]
      }
      .map { sunCycleCellItems -> [TableViewSectionData] in
        [WeatherStationCurrentInformationHeaderItemsSection(
          sectionCellsIdentifier: WeatherStationCurrentInformationSunCycleCell.reuseIdentifier,
          sectionItems: sunCycleCellItems
        )]
      }
    
    let weatherStationCurrentInformationAtmosphericDetailsSectionItemsObservable = weatherInformationDtoObservable // swiftlint:disable:this identifier_name
      .map { $0.entity }
      .map { weatherInformationDTO -> [BaseCellViewModelProtocol] in
        guard let cloudCoverage = weatherInformationDTO.cloudCoverage.coverage,
              let humidity = weatherInformationDTO.atmosphericInformation.humidity,
              let pressurePsi =  weatherInformationDTO.atmosphericInformation.pressurePsi else {
          return []
        }
        
        return [WeatherStationCurrentInformationAtmosphericDetailsCellViewModel(dependencies: WeatherStationCurrentInformationAtmosphericDetailsCellViewModel.Dependencies(
          cloudCoverage: cloudCoverage,
          humidity: humidity,
          pressurePsi: pressurePsi
        ))]
      }
      .map { atmosphericDetailsCellItems -> [TableViewSectionData] in
        [WeatherStationCurrentInformationAtmosphericDetailsItemsSection(
          sectionCellsIdentifier: WeatherStationCurrentInformationAtmosphericDetailsCell.reuseIdentifier,
          sectionItems: atmosphericDetailsCellItems
        )]
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
          return [WeatherStationCurrentInformationWindCellViewModel(dependencies: WeatherStationCurrentInformationWindCellViewModel.Dependencies(
            windSpeed: windspeed,
            windDirectionDegrees: windDirectionDegrees,
            dimensionaUnitsPreference: dimensionalUnitsOption
          ))]
        }
      )
      .map { windCellItems -> [TableViewSectionData] in
        [WeatherStationCurrentInformationWindItemsSection(
          sectionCellsIdentifier: WeatherStationCurrentInformationWindCell.reuseIdentifier,
          sectionItems: windCellItems
        )]
      }
    
    let weatherStationCurrentInformationMapSectionItemsObservable = weatherInformationDtoObservable
      .map { [dependencies] weatherInformationPersistencyModel -> [BaseCellViewModelProtocol] in
        guard weatherInformationPersistencyModel.entity.coordinates.latitude != nil,
              weatherInformationPersistencyModel.entity.coordinates.longitude != nil else {
          return []
        }
        return [WeatherStationCurrentInformationMapCellViewModel(dependencies: WeatherStationCurrentInformationMapCellViewModel.Dependencies(
          weatherInformationIdentity: weatherInformationPersistencyModel.identity,
          weatherStationService: dependencies.weatherStationService,
          weatherInformationService: dependencies.weatherInformationService,
          preferencesService: dependencies.preferencesService,
          userLocationService: dependencies.userLocationService
        ))]
      }
      .map { mapCellItems -> [TableViewSectionData] in
        [WeatherStationCurrentInformationMapItemsSection(
          sectionCellsIdentifier: WeatherStationCurrentInformationMapCell.reuseIdentifier,
          sectionItems: mapCellItems
        )]
      }
      
    Observable
      .combineLatest(
        weatherStationCurrentInformationHeaderSectionItemsObservable,
        weatherStationCurrentInformationSunCycleSectionItemsObservable,
        weatherStationCurrentInformationAtmosphericDetailsSectionItemsObservable,
        weatherStationCurrentInformationWindSectionItemsObservable,
        weatherStationCurrentInformationMapSectionItemsObservable,
        resultSelector: { headerSectionItems, sunCycleSectionItems, atmosphericDetailsSectionItems, windSectionItems, mapSectionItems -> [TableViewSectionData] in
          headerSectionItems + sunCycleSectionItems + atmosphericDetailsSectionItems + windSectionItems + mapSectionItems
        }
      )
      .bind { [weak tableDataSource] in tableDataSource?.sectionDataSources.accept($0) }
      .disposed(by: disposeBag)
  }
  
  func observeUserTapEvents() {} // nothing to do - will be used in the future
}

// MARK: - Observation Helpers

private extension WeatherStationCurrentInformationViewModel {
  
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

extension WeatherStationCurrentInformationViewModel: BaseTableViewSelectionDelegate {
  
  func didSelectRow(at indexPath: IndexPath) {} // nothing to do - will be used in the future
}
