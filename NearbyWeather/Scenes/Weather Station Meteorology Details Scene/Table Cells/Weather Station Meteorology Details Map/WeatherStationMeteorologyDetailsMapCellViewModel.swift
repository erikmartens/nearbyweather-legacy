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
import PKHUD

// MARK: - Dependencies

extension WeatherStationMeteorologyDetailsMapCellViewModel {
  struct Dependencies {
    let weatherInformationIdentity: PersistencyModelIdentity
    let weatherStationService: WeatherStationBookmarkReading
    let weatherInformationService: WeatherInformationReading
    let preferencesService: WeatherMapPreferenceReading
  }
}

// MARK: - Class Definition

final class WeatherStationMeteorologyDetailsMapCellViewModel: NSObject, BaseCellViewModel {
  
  let associatedCellReuseIdentifier = WeatherStationMeteorologyDetailsMapCell.reuseIdentifier
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  var mapDelegate: WeatherStationMeteorologyDetailsMapCellMapViewDelegate? // swiftlint:disable:this weak_delegate

  // MARK: - Events
  
  lazy var cellModelDriver: Driver<WeatherStationMeteorologyDetailsMapCellModel> = dependencies.preferencesService
    .createGetMapTypeOptionObservable()
    .map { preferredMapTypeOption -> WeatherStationMeteorologyDetailsMapCellModel in
      WeatherStationMeteorologyDetailsMapCellModel(
        preferredMapTypeOption: preferredMapTypeOption
      )
    }
    .asDriver(onErrorJustReturn: WeatherStationMeteorologyDetailsMapCellModel())
  
  lazy var weatherStationLocationObservable: Observable<CLLocationCoordinate2D?> = weatherInformationDtoObservable
    .map { $0.entity.coordinates }
    .map { coordinates in
      guard let latitude = coordinates.latitude, let longitude = coordinates.longitude else {
        return nil
      }
      return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
  
  // MARK: - Observables
  
  private lazy var weatherInformationDtoObservable = Observable
    .combineLatest(
      Observable.just(dependencies.weatherInformationIdentity.identifier),
      dependencies.weatherStationService.createGetIsStationBookmarkedObservable(for: dependencies.weatherInformationIdentity)
    )
    .flatMapLatest(dependencies.weatherInformationService.createGetWeatherInformationItemObservable)
    .share(replay: 1)

  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
    super.init()
    
    mapDelegate = WeatherStationMeteorologyDetailsMapCellMapViewDelegate(annotationSelectionDelegate: self, annotationViewType: WeatherStationLocationAnnotationView.self)
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
      .map { weatherInformationDTO in [weatherInformationDTO].mapToWeatherStationLocationMapAnnotationViewModel() }
      .map {
        WeatherMapAnnotationData(
          annotationViewReuseIdentifier: WeatherStationLocationAnnotationView.reuseIdentifier,
          annotationItems: $0
        )
      }
      .bind { [weak mapDelegate] in mapDelegate?.dataSource.accept($0) }
      .disposed(by: disposeBag)
  }
}

// MARK: - Delegate Extensions

extension WeatherStationMeteorologyDetailsMapCellViewModel: BaseMapViewSelectionDelegate {
  
  func didSelectView(for annotationViewModel: BaseAnnotationViewModelProtocol) {
    // nothing to do - nothing should happen when the annotation is tapped
  }
}

// MARK: - Private Helpers

private extension Array where Element == PersistencyModelThreadSafe<WeatherInformationDTO> {
  
  func mapToWeatherStationLocationMapAnnotationViewModel() -> [BaseAnnotationViewModelProtocol] {
    compactMap { weatherInformationPersistencyModel -> WeatherStationLocationMapAnnotationViewModel? in
      guard let latitude = weatherInformationPersistencyModel.entity.coordinates.latitude,
            let longitude = weatherInformationPersistencyModel.entity.coordinates.longitude else {
        return nil
      }
      return WeatherStationLocationMapAnnotationViewModel(dependencies: WeatherStationLocationMapAnnotationViewModel.Dependencies(
        coordinate: CLLocationCoordinate2D(
          latitude: latitude,
          longitude: longitude
        )))
    }
  }
}
