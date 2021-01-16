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
    let weatherInformationService: WeatherInformationReading
    let preferencesService: WeatherMapPreferenceReading
    let userLocationService: UserLocationReading
    let weatherInformationIdentity: PersistencyModelIdentityProtocol
    let isBookmark: Bool
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
  
  let cellModelDriver: Driver<WeatherStationCurrentInformationMapCellModel>
  
  // MARK: - Observables
  
  private lazy var weatherInformationDtoObservable: Observable<PersistencyModel<WeatherInformationDTO>> = { [dependencies] in
    Self.createGetWeatherInformationDtoObservable(with: dependencies)
  }()

  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
    cellModelDriver = Self.createDataSourceObserver(with: dependencies)
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
          weatherInformationService: dependencies.weatherInformationService,
          preferencesService: dependencies.preferencesService,
          isBookmark: dependencies.isBookmark,
          selectionDelegate: nil
        )
      }
      .map {
        WeatherMapAnnotationData(
          annotationViewReuseIdentifier: WeatherMapAnnotationView.reuseIdentifier,
          annotationItems: $0
        )
      }
      .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
      .bind { [weak mapDelegate] in mapDelegate?.dataSource.accept($0) }
      .disposed(by: disposeBag)
  }
}

private extension WeatherStationCurrentInformationMapCellViewModel {
  
  static func createDataSourceObserver(with dependencies: Dependencies) -> Driver<WeatherStationCurrentInformationMapCellModel> {
    Observable
      .combineLatest(
        createGetWeatherInformationDtoObservable(with: dependencies).map { $0.entity },
        dependencies.preferencesService.createGetMapTypeOptionObservable(),
        dependencies.preferencesService.createGetDimensionalUnitsOptionObservable(),
        dependencies.userLocationService.createGetCurrentLocationOptionalObservable(),
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
  
  static func createGetWeatherInformationDtoObservable(with dependencies: Dependencies) -> Observable<PersistencyModel<WeatherInformationDTO>> {
    dependencies.weatherInformationService
      .createGetWeatherInformationItemObservable(
        for: dependencies.weatherInformationIdentity.identifier,
        isBookmark: dependencies.isBookmark
      )
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
