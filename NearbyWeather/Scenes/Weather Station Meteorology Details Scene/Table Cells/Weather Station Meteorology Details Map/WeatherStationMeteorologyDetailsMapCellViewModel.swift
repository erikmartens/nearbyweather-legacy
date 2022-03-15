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

extension WeatherStationMeteorologyDetailsMapCellViewModel {
  struct Dependencies {
    let weatherInformationIdentity: PersistencyModelIdentity
    let weatherStationService: WeatherStationBookmarkReading
    let weatherInformationService: WeatherInformationReading
    let preferencesService: WeatherMapPreferenceReading
    let userLocationService: UserLocationReading
  }
}

// MARK: - Class Definition

final class WeatherStationMeteorologyDetailsMapCellViewModel: NSObject, BaseCellViewModel {
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  var mapDelegate: WeatherStationMeteorologyDetailsMapCellMapViewDelegate? // swiftlint:disable:this weak_delegate

  // MARK: - Events
  
  lazy var cellModelDriver: Driver<WeatherStationMeteorologyDetailsMapCellModel> = { [dependencies] in
    Self.createCellModelDriver(with: dependencies)
  }()
  
  // MARK: - Observables
  
  private lazy var weatherInformationDtoObservable: Observable<PersistencyModelThreadSafe<WeatherInformationDTO>> = { [dependencies] in
    Self.createGetWeatherInformationDtoObservable(with: dependencies).share(replay: 1)
  }()

  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
    super.init()
    
    mapDelegate = WeatherStationMeteorologyDetailsMapCellMapViewDelegate(annotationSelectionDelegate: self, annotationViewType: WeatherMapAnnotationView.self)
  }
  
  // MARK: - Functions
  
  func observeEvents() {
    observeDataSource()
    observeUserTapEvents()
  }
}

// MARK: - Observations

extension WeatherStationMeteorologyDetailsMapCellViewModel {
  
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

private extension WeatherStationMeteorologyDetailsMapCellViewModel {
  
  static func createCellModelDriver(with dependencies: Dependencies) -> Driver<WeatherStationMeteorologyDetailsMapCellModel> {
    Observable
      .combineLatest(
        createGetWeatherInformationDtoObservable(with: dependencies).map { $0.entity },
        dependencies.preferencesService.createGetMapTypeOptionObservable(),
        dependencies.preferencesService.createGetDimensionalUnitsOptionObservable(),
        dependencies.userLocationService.createGetUserLocationObservable(),
        resultSelector: { weatherInformationDTO, preferredMapTypeOption, preferredDimensionalUnitsOption, currentLocation -> WeatherStationMeteorologyDetailsMapCellModel in
          WeatherStationMeteorologyDetailsMapCellModel(
            preferredMapTypeOption: preferredMapTypeOption,
            coordinatesString: String
              .begin(with: weatherInformationDTO.coordinates.latitude)
              .append(contentsOfConvertible: weatherInformationDTO.coordinates.longitude, delimiter: .comma, emptyIfPredecessorWasEmpty: true)
              .ifEmpty(justReturn: nil),
            distanceString: Self.distanceString(for: weatherInformationDTO, preferredDimensionalUnitsOption: preferredDimensionalUnitsOption, currentLocation: currentLocation)
          )
        }
      )
      .asDriver(onErrorJustReturn: WeatherStationMeteorologyDetailsMapCellModel())
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

// MARK: - Delegate Extensions

extension WeatherStationMeteorologyDetailsMapCellViewModel: BaseMapViewSelectionDelegate {
  
  func didSelectView(for annotationViewModel: BaseAnnotationViewModelProtocol) {
    // nothing to do - nothing should happen when the annotation is tapped
  }
}

// MARK: - Private Helpers

private extension WeatherStationMeteorologyDetailsMapCellViewModel {
  
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
