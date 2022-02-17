//
//  WeatherStationCurrentInformationMapCellViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 16.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa
import CoreLocation

// MARK: - Dependencies

extension WeatherStationCurrentInformationMapCellViewModel {
  struct Dependencies {
    let weatherInformationIdentity: PersistencyModelIdentityProtocol
    let weatherStationService: WeatherStationBookmarkReading
    let weatherInformationService: WeatherInformationReading
    let preferencesService: WeatherMapPreferenceReading
    let userLocationService: UserLocationReading
  }
}

// MARK: - Class Definition

final class WeatherStationCurrentInformationMapCellViewModel: NSObject, BaseCellViewModel {
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  var mapDelegate: WeatherStationCurrentInformationMapCellMapViewDelegate? // swiftlint:disable:this weak_delegate

  // MARK: - Events
  
  lazy var cellModelDriver: Driver<WeatherStationCurrentInformationMapCellModel> = { [dependencies] in
    Self.createCellModelDriver(with: dependencies)
  }()
  
  // MARK: - Observables
  
  private lazy var weatherInformationDtoObservable: Observable<PersistencyModelThreadSafe<WeatherInformationDTO>> = { [dependencies] in
    Self.createGetWeatherInformationDtoObservable(with: dependencies).share(replay: 1)
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

// MARK: - Observations

extension WeatherStationCurrentInformationMapCellViewModel {
  
  func observeDataSource() {
    weatherInformationDtoObservable
      .map { [dependencies] weatherInformationDTO in
        [weatherInformationDTO].mapToWeatherMapAnnotationViewModel(
          weatherStationService: dependencies.weatherStationService,
          weatherInformationService: dependencies.weatherInformationService,
          preferencesService: dependencies.preferencesService,
          selectionDelegate: nil
        )
      }
      .map {
        WeatherMapAnnotationData(
          annotationViewReuseIdentifier: WeatherMapAnnotationView.reuseIdentifier,
          annotationItems: $0
        )
      }
      .bind { [weak mapDelegate] in mapDelegate?.dataSource.accept($0) }
      .disposed(by: disposeBag)
  }
}

// MARK: - Observation Helpers

private extension WeatherStationCurrentInformationMapCellViewModel {
  
  static func createCellModelDriver(with dependencies: Dependencies) -> Driver<WeatherStationCurrentInformationMapCellModel> {
    Observable
      .combineLatest(
        createGetWeatherInformationDtoObservable(with: dependencies).map { $0.entity },
        dependencies.preferencesService.createGetMapTypeOptionObservable(),
        dependencies.preferencesService.createGetDimensionalUnitsOptionObservable(),
        dependencies.userLocationService.createGetCurrentLocationObservable().map { location -> CLLocation? in location },
        resultSelector: { weatherInformationDTO, preferredMapTypeOption, preferredDimensionalUnitsOption, currentLocation -> WeatherStationCurrentInformationMapCellModel in
          WeatherStationCurrentInformationMapCellModel(
            preferredMapTypeOption: preferredMapTypeOption,
            coordinatesString: String
              .begin(with: weatherInformationDTO.coordinates.latitude)
              .append(contentsOfConvertible: weatherInformationDTO.coordinates.longitude, delimiter: .comma, emptyIfPredecessorWasEmpty: true)
              .ifEmpty(justReturn: nil),
            distanceString: Self.distanceString(for: weatherInformationDTO, preferredDimensionalUnitsOption: preferredDimensionalUnitsOption, currentLocation: currentLocation)
          )
        }
      )
      .asDriver(onErrorJustReturn: WeatherStationCurrentInformationMapCellModel())
  }
  
  static func createGetWeatherStationIsBookmarkedObservable(with dependencies: Dependencies) -> Observable<Bool> {
    dependencies.weatherStationService.createGetIsStationBookmarkedObservable(for: dependencies.weatherInformationIdentity)
  }
  
  static func createGetWeatherInformationDtoObservable(with dependencies: Dependencies) -> Observable<PersistencyModelThreadSafe<WeatherInformationDTO>> {
    Observable
      .combineLatest(
        Observable.just(dependencies.weatherInformationIdentity.identifier),
        Self.createGetWeatherStationIsBookmarkedObservable(with: dependencies)
      )
      .flatMapLatest(dependencies.weatherInformationService.createGetWeatherInformationItemObservable)
  }
}

// MARK: - Private Helpers

private extension WeatherStationCurrentInformationMapCellViewModel {
  
  static func distanceString(for weatherInformationDTO: WeatherInformationDTO, preferredDimensionalUnitsOption: DimensionalUnitsOption, currentLocation: CLLocation?) -> String? {
    guard let currentLocation = currentLocation,
          let weatherStationLatitude = weatherInformationDTO.coordinates.latitude,
          let weatherStationLongitude = weatherInformationDTO.coordinates.longitude else {
      return nil
    }
    let weatherStationlocation = CLLocation(latitude: weatherStationLatitude, longitude: weatherStationLongitude)
    let distanceInMetres = currentLocation.distance(from: weatherStationlocation)
    
    return ConversionWorker.distanceDescriptor(forDistanceSpeedUnit: preferredDimensionalUnitsOption, forDistanceInMetres: distanceInMetres)
  }
}
