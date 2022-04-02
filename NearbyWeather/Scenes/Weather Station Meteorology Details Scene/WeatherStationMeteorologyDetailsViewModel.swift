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
import PKHUD

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
  
  lazy var navigationBarTitleDriver: Driver<String?> = weatherInformationDtoObservable
    .map { $0.entity.stationName }
    .asDriver(onErrorJustReturn: nil)
  
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

  func observeDataSource() { // swiftlint:disable:this cyclomatic_complexity
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
    
    let dayCycleStringsObservable = weatherInformationDtoObservable
      .map { $0.entity }
      .map { MeteorologyInformationConversionWorker.dayCycleTimeStrings(for: $0.dayTimeInformation, coordinates: $0.coordinates) }
      .share(replay: 1)
    
    let weatherStationCurrentInformationSunCycleSectionItemsObservable = dayCycleStringsObservable // swiftlint:disable:this identifier_name
      .map { dayCycleStrings -> [WeatherStationMeteorologyDetailsSymbolCellViewModel] in
        var results = [WeatherStationMeteorologyDetailsSymbolCellViewModel]()
        
        if let currentTimeString = dayCycleStrings?.currentTimeString {
          results.append(WeatherStationMeteorologyDetailsSymbolCellViewModel(dependencies: WeatherStationMeteorologyDetailsSymbolCellViewModel.Dependencies(
            symbolImageName: "clock",
            contentLabelText: R.string.localizable.current_time().capitalized,
            descriptionLabelText: currentTimeString
          )))
        }
        
        if let sunriseTimeString = dayCycleStrings?.sunriseTimeString {
          results.append(WeatherStationMeteorologyDetailsSymbolCellViewModel(dependencies: WeatherStationMeteorologyDetailsSymbolCellViewModel.Dependencies(
            symbolImageName: "sunrise.fill",
            contentLabelText: R.string.localizable.sunrise().capitalized,
            descriptionLabelText: sunriseTimeString
          )))
        }
        
        if let sunsetTimeString = dayCycleStrings?.sunsetTimeString {
          results.append(WeatherStationMeteorologyDetailsSymbolCellViewModel(dependencies: WeatherStationMeteorologyDetailsSymbolCellViewModel.Dependencies(
            symbolImageName: "sunset.fill",
            contentLabelText: R.string.localizable.sunset().capitalized,
            descriptionLabelText: sunsetTimeString
          )))
        }
        
        return results
      }
      .map { sunCycleCellItems -> [TableViewSectionDataProtocol] in
        [WeatherStationMeteorologyDetailsHeaderItemsSection(sectionItems: sunCycleCellItems)]
      }
    
    let weatherStationCurrentInformationAtmosphericDetailsSectionItemsObservable = weatherInformationDtoObservable // swiftlint:disable:this identifier_name
      .map { $0.entity }
      .map { weatherInformationModel -> [WeatherStationMeteorologyDetailsSymbolCellViewModel] in
        var results = [WeatherStationMeteorologyDetailsSymbolCellViewModel]()
        
        if let cloudCoverageDescriptor = MeteorologyInformationConversionWorker.cloudCoverageDescriptor(for: weatherInformationModel.cloudCoverage.coverage) {
          results.append(WeatherStationMeteorologyDetailsSymbolCellViewModel(dependencies: WeatherStationMeteorologyDetailsSymbolCellViewModel.Dependencies(
            symbolImageName: "cloud",
            contentLabelText: R.string.localizable.cloud_coverage().capitalized,
            descriptionLabelText: cloudCoverageDescriptor
          )))
        }
        
        if let humidityDescriptor = MeteorologyInformationConversionWorker.humidityDescriptor(for: weatherInformationModel.atmosphericInformation.humidity) {
          results.append(WeatherStationMeteorologyDetailsSymbolCellViewModel(dependencies: WeatherStationMeteorologyDetailsSymbolCellViewModel.Dependencies(
            symbolImageName: "humidity",
            contentLabelText: R.string.localizable.humidity().capitalized,
            descriptionLabelText: humidityDescriptor
          )))
        }
        
        if let airPressureDescriptor = MeteorologyInformationConversionWorker.airPressureDescriptor(for: weatherInformationModel.atmosphericInformation.pressurePsi) {
          results.append(WeatherStationMeteorologyDetailsSymbolCellViewModel(dependencies: WeatherStationMeteorologyDetailsSymbolCellViewModel.Dependencies(
            symbolImageName: "gauge",
            contentLabelText: R.string.localizable.air_pressure().capitalized,
            descriptionLabelText: airPressureDescriptor
          )))
        }
        
        return results
      }
      .map { atmosphericDetailsCellItems -> [TableViewSectionDataProtocol] in
        [WeatherStationMeteorologyDetailsAtmosphericDetailsItemsSection(sectionItems: atmosphericDetailsCellItems)]
      }
    
    let weatherStationCurrentInformationWindSectionItemsObservable = Observable
      .combineLatest(
        weatherInformationDtoObservable.map { $0.entity },
        dimensionalUnitsOptionObservable,
        resultSelector: { weatherInformationModel, dimensionalUnitsOption in
          var results = [WeatherStationMeteorologyDetailsSymbolCellViewModel]()
          
          if let windspeedDescriptor = MeteorologyInformationConversionWorker.windspeedDescriptor(
            forDistanceSpeedUnit: dimensionalUnitsOption, forWindspeed: weatherInformationModel.windInformation.windspeed) {
            results.append(WeatherStationMeteorologyDetailsSymbolCellViewModel(dependencies: WeatherStationMeteorologyDetailsSymbolCellViewModel.Dependencies(
              symbolImageName: "wind",
              contentLabelText: R.string.localizable.windspeed().capitalized,
              descriptionLabelText: windspeedDescriptor
            )))
          }
          
          if let windDirectionDegrees = weatherInformationModel.windInformation.degrees, let airPressureDescriptor = MeteorologyInformationConversionWorker.windDirectionDescriptor(forWindDirection: windDirectionDegrees) {
            results.append(WeatherStationMeteorologyDetailsSymbolCellViewModel(dependencies: WeatherStationMeteorologyDetailsSymbolCellViewModel.Dependencies(
              symbolImageName: "arrow.down.circle",
              symbolImageRotationAngle: CGFloat(windDirectionDegrees)*0.0174532925199, // convert to radians
              contentLabelText: R.string.localizable.wind_direction().capitalized,
              descriptionLabelText: airPressureDescriptor
            )))
          }
          
          return results
        }
      )
      .map { windCellItems -> [TableViewSectionDataProtocol] in
        [WeatherStationMeteorologyDetailsWindItemsSection(sectionItems: windCellItems)]
      }
    
    let weatherStationCurrentInformationMapSectionItemsObservable = Observable
      .combineLatest(
        weatherInformationDtoObservable,
        dimensionalUnitsOptionObservable,
        dependencies.userLocationService.createGetUserLocationObservable(),
        resultSelector: { [unowned self] weatherInformationPersistencyModel, dimensionalUnitsOption, currentLocation -> [BaseCellViewModelProtocol] in
          var results = [BaseCellViewModelProtocol]()
          
          guard let latitude = weatherInformationPersistencyModel.entity.coordinates.latitude,
                let longitude = weatherInformationPersistencyModel.entity.coordinates.longitude else {
            return results
          }
          
          results.append(WeatherStationMeteorologyDetailsMapCellViewModel(dependencies: WeatherStationMeteorologyDetailsMapCellViewModel.Dependencies(
            weatherInformationIdentity: weatherInformationPersistencyModel.identity,
            weatherStationService: dependencies.weatherStationService,
            weatherInformationService: dependencies.weatherInformationService,
            preferencesService: dependencies.preferencesService
          )))
          
          if let coordinateDescriptor = MeteorologyInformationConversionWorker.coordinatesDescriptorFor(latitude: latitude, longitude: longitude) {
            results.append(WeatherStationMeteorologyDetailsSymbolCellViewModel(dependencies: WeatherStationMeteorologyDetailsSymbolCellViewModel.Dependencies(
              symbolImageName: "mappin.and.ellipse",
              contentLabelText: R.string.localizable.coordinates().capitalized,
              descriptionLabelText: coordinateDescriptor,
              copyText: MeteorologyInformationConversionWorker.coordinatesCopyTextFor(latitude: latitude, longitude: longitude),
              selectable: true
            )))
          }
          
          if let distanceDescriptor = Self.distanceString(for: weatherInformationPersistencyModel.entity, preferredDimensionalUnitsOption: dimensionalUnitsOption, currentLocation: currentLocation) {
            results.append(WeatherStationMeteorologyDetailsSymbolCellViewModel(dependencies: WeatherStationMeteorologyDetailsSymbolCellViewModel.Dependencies(
              symbolImageName: "ruler",
              contentLabelText: R.string.localizable.distance().capitalized,
              descriptionLabelText: distanceDescriptor
            )))
          }
          
          return results
        }
      )
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
      .map { $0.compactMap { $0.sectionItems.isEmpty ? nil : $0 } } // remove empty sections
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

// MARK: - Helpers

private extension WeatherStationMeteorologyDetailsViewModel {
  
  static func distanceString(for weatherInformationDTO: WeatherInformationDTO, preferredDimensionalUnitsOption: DimensionalUnitOption, currentLocation: CLLocation?) -> String? {
    guard let currentLocation = currentLocation,
          let weatherStationLatitude = weatherInformationDTO.coordinates.latitude,
          let weatherStationLongitude = weatherInformationDTO.coordinates.longitude else {
      return nil
    }
    let weatherStationlocation = CLLocation(latitude: weatherStationLatitude, longitude: weatherStationLongitude)
    let distanceInMetres = currentLocation.distance(from: weatherStationlocation)
    
    return MeteorologyInformationConversionWorker.distanceDescriptor(forDistanceSpeedUnit: preferredDimensionalUnitsOption, forDistanceInMetres: distanceInMetres)
  }
}

// MARK: - Delegate Extensions

extension WeatherStationMeteorologyDetailsViewModel: BaseTableViewSelectionDelegate {
  
  func didSelectRow(at indexPath: IndexPath) {
    guard let symbolCellViewModel = tableDataSource.sectionDataSources[indexPath] as? WeatherStationMeteorologyDetailsSymbolCellViewModel,
            let copyText = symbolCellViewModel.copyText else {
      return
    }
    
    UIPasteboard.general.string = copyText
    HUD.flash(.label(R.string.localizable.copied().capitalized), delay: 0.5)
//    onDidTapCoordinatesLabelSubject
//      .asObservable()
//      .withLatestFrom(weatherInformationDtoObservable.map { $0.entity })
//      .subscribe(on: MainScheduler.instance)
//      .subscribe(onNext: { weatherInformationModel in
//        UIPasteboard.general.string = MeteorologyInformationConversionWorker.coordinatesCopyTextFor(
//          latitude: weatherInformationModel.coordinates.latitude,
//          longitude: weatherInformationModel.coordinates.longitude
//        )
//
//        let message = String
//          .begin(with: R.string.localizable.coordinates().capitalized)
//          .append(contentsOf: R.string.localizable.copied().capitalized, delimiter: .space)
//
//        HUD.flash(.label(message), delay: 0.5)
//      })
//      .disposed(by: disposeBag)
  }
}
