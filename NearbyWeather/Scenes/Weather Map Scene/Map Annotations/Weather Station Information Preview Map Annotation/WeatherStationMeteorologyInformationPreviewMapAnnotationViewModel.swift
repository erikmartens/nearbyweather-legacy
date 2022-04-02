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

extension WeatherStationMeteorologyInformationPreviewMapAnnotationViewModel {
  struct Dependencies {
    let weatherInformationIdentity: PersistencyModelIdentity
    let coordinate: CLLocationCoordinate2D
    let weatherStationService: WeatherStationBookmarkReading
    let weatherInformationService: WeatherInformationReading
    let preferencesService: WeatherMapPreferenceReading
    weak var annotationSelectionDelegate: BaseMapViewSelectionDelegate?
  }
}

// MARK: - Class Definition

final class WeatherStationMeteorologyInformationPreviewMapAnnotationViewModel: NSObject, BaseAnnotationViewModel { // swiftlint:disable:this type_name
  
  // MARK: - Public Access
  
  var weatherInformationIdentity: PersistencyModelIdentity {
    dependencies.weatherInformationIdentity
  }
  
  var coordinate: CLLocationCoordinate2D {
    dependencies.coordinate
  }
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  private let dependencies: Dependencies

  // MARK: - Events
  
  let onDidTapAnnotationView = PublishSubject<Void>()
  
  // MARK: - Drivers
  
  lazy var annotationModelDriver: Driver<WeatherStationMeteorologyInformationPreviewAnnotationModel> = { [dependencies] in
    Self.createDataSourceObserver(with: dependencies)
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

extension WeatherStationMeteorologyInformationPreviewMapAnnotationViewModel {
  
  func observeUserTapEvents() {
    onDidTapAnnotationView
      .subscribe(onNext: { [dependencies] _ in
        dependencies.annotationSelectionDelegate?.didSelectView(for: self)
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - Observation Helpers

private extension WeatherStationMeteorologyInformationPreviewMapAnnotationViewModel {
  
  static func createDataSourceObserver(with dependencies: Dependencies) -> Driver<WeatherStationMeteorologyInformationPreviewAnnotationModel> {
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
        weatherStationIsBookmarkedObservable,
        resultSelector: { weatherInformationModel, temperatureUnitOption, isBookmark -> WeatherStationMeteorologyInformationPreviewAnnotationModel in
          WeatherStationMeteorologyInformationPreviewAnnotationModel(
            weatherInformationDTO: weatherInformationModel,
            temperatureUnitOption: temperatureUnitOption,
            isBookmark: isBookmark
          )
        }
      )
      .asDriver(onErrorJustReturn: WeatherStationMeteorologyInformationPreviewAnnotationModel())
  }
  
  static func createGetWeatherStationIsBookmarkedObservable(with dependencies: Dependencies) -> Observable<Bool> {
    dependencies.weatherStationService.createGetIsStationBookmarkedObservable(for: dependencies.weatherInformationIdentity)
  }
}
