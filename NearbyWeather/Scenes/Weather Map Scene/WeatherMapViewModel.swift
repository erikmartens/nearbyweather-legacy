//
//  WeatherMapViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 10.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import CoreLocation
import RxSwift
import RxCocoa
import RxOptional
import RxFlow

// MARK: - Dependencies

extension WeatherMapViewModel {
  struct Dependencies {
    let weatherInformationService: WeatherInformationPersistence & WeatherInformationUpdating
    let weatherStationService: WeatherStationBookmarkReading
    let userLocationService: UserLocationReading
    let preferencesService: WeatherMapPreferencePersistence
    let apiKeyService: ApiKeyReading
  }
}

// MARK: - Class Definition

final class WeatherMapViewModel: NSObject, Stepper, BaseViewModel {
  
  // MARK: - Routing
  
  let steps = PublishRelay<Step>()
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  var mapDelegate: WeatherMapMapViewDelegate? // swiftlint:disable:this weak_delegate
  
  // MARK: - Events
  
  let onDidTapMapTypeBarButtonSubject = PublishSubject<Void>()
  let onDidTapAmountOfResultsBarButtonSubject = PublishSubject<Void>()
  let onDidTapFocusOnLocationBarButtonSubject = PublishSubject<Void>()
  let onShouldFocusOnLocationSubject = BehaviorSubject<CLLocationCoordinate2D?>(value: nil)
  
  // MARK: - Drivers
  
  lazy var preferredMapTypeDriver = preferredMapTypeObservable.asDriver(onErrorJustReturn: .standard)
  lazy var preferredAmountOfResultsDriver = preferredAmountOfResultsObservable.asDriver(onErrorJustReturn: .ten)
  lazy var focusOnLocationDriver: Driver<CLLocationCoordinate2D?> = onShouldFocusOnLocationSubject.asDriver(onErrorJustReturn: nil)
  
  // MARK: - Observables
  
  private lazy var preferredMapTypeObservable: Observable<MapTypeOptionValue> = dependencies
    .preferencesService
    .createGetMapTypeOptionObservable()
    .map { $0.value }
    .share(replay: 1)
  
  private lazy var preferredAmountOfResultsObservable: Observable<AmountOfResultsOptionValue>  = dependencies
    .preferencesService
    .createGetAmountOfNearbyResultsOptionObservable()
    .map { $0.value }
    .share(replay: 1)
  
  // MARK: - Initialization
  
  required init(dependencies: Dependencies) {
    self.dependencies = dependencies
    super.init()
    
    mapDelegate = WeatherMapMapViewDelegate(annotationSelectionDelegate: self, annotationViewType: WeatherStationMeteorologyInformationPreviewAnnotationView.self)
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

extension WeatherMapViewModel {
  
  func observeDataSource() {
    let apiKeyValidObservable = dependencies
      .apiKeyService
      .createGetApiKeyObservable()
      .share(replay: 1)
    
    let nearbyMapItemsObservable = Observable
      .combineLatest(
        dependencies.weatherInformationService.createGetNearbyWeatherInformationListObservable(),
        apiKeyValidObservable,
        resultSelector: { [unowned self] weatherInformationList, _ in
          weatherInformationList.mapToWeatherMapAnnotationViewModel(
            weatherStationService: dependencies.weatherStationService,
            weatherInformationService: dependencies.weatherInformationService,
            preferencesService: dependencies.preferencesService,
            selectionDelegate: self
          )
        }
      )
      .catchAndReturn([])
      .share(replay: 1)
    
    let bookmarkedMapItemsObservable = Observable
      .combineLatest(
        dependencies.weatherInformationService.createGetBookmarkedWeatherInformationListObservable(),
        apiKeyValidObservable,
        resultSelector: { [unowned self] weatherInformationList, _ in
          weatherInformationList.mapToWeatherMapAnnotationViewModel(
            weatherStationService: dependencies.weatherStationService,
            weatherInformationService: dependencies.weatherInformationService,
            preferencesService: dependencies.preferencesService,
            selectionDelegate: self
          )
        }
      )
      .catchAndReturn([])
      .share(replay: 1)
    
    Observable
      .combineLatest(
        nearbyMapItemsObservable,
        bookmarkedMapItemsObservable,
        resultSelector: { nearbyAnnotations, bookmarkedAnnotations in
          var mutableNearbyAnnotations = nearbyAnnotations
          
          mutableNearbyAnnotations.removeAll { nearbyAnnotation -> Bool in
            bookmarkedAnnotations.contains { bookmarkedAnnotation -> Bool in
              let nearbyIdentifier = (nearbyAnnotation as? WeatherStationMeteorologyInformationPreviewMapAnnotationViewModel)?.weatherInformationIdentity.identifier
              let bookmarkedIdentifier = (bookmarkedAnnotation as? WeatherStationMeteorologyInformationPreviewMapAnnotationViewModel)?.weatherInformationIdentity.identifier
              return nearbyIdentifier == bookmarkedIdentifier
            }
          }
          
          return WeatherMapAnnotationData(
            annotationViewReuseIdentifier: WeatherStationMeteorologyInformationPreviewAnnotationView.reuseIdentifier,
            annotationItems: mutableNearbyAnnotations + bookmarkedAnnotations
          )
        }
      )
      .bind { [weak mapDelegate] in mapDelegate?.dataSource.accept($0) }
      .disposed(by: disposeBag)
    
    dependencies.userLocationService
      .createGetUserLocationObservable()
      .flatMapLatest { [unowned self] userLocation -> Observable<CLLocationCoordinate2D?> in
        if let userLocation = userLocation {
          return Observable.just(CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude))
        }
        return dependencies.weatherStationService
          .createGetPreferredBookmarkObservable()
          .map { $0?.value.stationIdentifier }
          .flatMapLatest { [unowned self] stationIdentifier -> Observable<Int?> in
            if let stationIdentifier = stationIdentifier {
              return Observable.just(stationIdentifier)
            }
            return dependencies.weatherStationService
              .createGetBookmarksSortingObservable()
              .map { sorting in
                guard let sorting = sorting, sorting.count >= 1 else {
                  return nil
                }
                return sorting[0]
              }
          }
          .flatMapLatest { [unowned self] stationIdentifier -> Observable<CLLocationCoordinate2D?> in
            guard let stationIdentifier = stationIdentifier else {
              return Observable.just(nil)
            }
            return dependencies.weatherInformationService
              .createGetBookmarkedWeatherInformationItemObservable(for: String(stationIdentifier))
              .map { $0.entity.coordinates.clLocationCoordinate2D }
          }
      }
      .take(1)
      .asSingle()
      .subscribe(onSuccess: { [unowned self] location in
        onShouldFocusOnLocationSubject.onNext(location)
      })
      .disposed(by: disposeBag)
  }
  
  func observeUserTapEvents() {    
    onDidTapMapTypeBarButtonSubject
      .subscribe(onNext: { [unowned self] _ in
        steps.accept(WeatherMapStep.changeMapTypeAlert(selectionDelegate: self))
      })
      .disposed(by: disposeBag)
    
    onDidTapAmountOfResultsBarButtonSubject
      .subscribe(onNext: { [unowned self] _ in
        steps.accept(WeatherMapStep.changeAmountOfResultsAlert(selectionDelegate: self))
      })
      .disposed(by: disposeBag)
    
    onDidTapFocusOnLocationBarButtonSubject
      .subscribe(onNext: { [unowned self] _ in
        steps.accept(WeatherMapStep.focusOnLocationAlert(selectionDelegate: self))
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - Delegate Extensions

extension WeatherMapViewModel: BaseMapViewSelectionDelegate {
  
  func didSelectView(for annotationViewModel: BaseAnnotationViewModelProtocol) {
    guard let annotationViewModel = annotationViewModel as? WeatherStationMeteorologyInformationPreviewMapAnnotationViewModel else {
      return
    }
    _ = Observable
      .just(annotationViewModel.weatherInformationIdentity)
      .map(WeatherMapStep.weatherDetails2)
      .take(1)
      .asSingle()
      .subscribe(onSuccess: steps.accept)
  }
}

extension WeatherMapViewModel: FocusOnLocationSelectionAlertDelegate {
  
  func didSelectFocusOnLocationOption(_ option: FocusOnLocationOption) {
    switch option {
    case .userLocation:
      dependencies.userLocationService
        .createGetUserLocationObservable()
        .take(1)
        .asSingle()
        .map { location -> CLLocationCoordinate2D? in
          guard let location = location else {
            return nil
          }
          return CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
        .subscribe(onSuccess: { [unowned self] in onShouldFocusOnLocationSubject.onNext($0) })
        .disposed(by: disposeBag)
    case let .weatherStation(location):
      Observable
        .just(location)
        .take(1)
        .asSingle()
        .map { location -> CLLocationCoordinate2D? in
          guard let location = location else {
            return nil
          }
          return CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
        .subscribe(onSuccess: { [unowned self] in onShouldFocusOnLocationSubject.onNext($0) })
        .disposed(by: disposeBag)
    }
  }
}

extension WeatherMapViewModel: MapTypeSelectionAlertDelegate {
  
  func didSelectMapTypeOption(_ selectedOption: MapTypeOption) {
    _ = dependencies.preferencesService
      .createSetPreferredMapTypeOptionCompletable(selectedOption)
      .subscribe()
  }
}

extension WeatherMapViewModel: AmountOfResultsSelectionAlertDelegate {
  
  func didSelectAmountOfResultsOption(_ selectedOption: AmountOfResultsOption) {
    _ = dependencies.preferencesService
      .createSetAmountOfNearbyResultsOptionCompletable(selectedOption)
      .subscribe()
  }
}

// MARK: - Private Helper Extensions

private extension Array where Element == PersistencyModelThreadSafe<WeatherInformationDTO> {
  
  func mapToWeatherMapAnnotationViewModel(
    weatherStationService: WeatherStationBookmarkReading,
    weatherInformationService: WeatherInformationReading,
    preferencesService: WeatherMapPreferenceReading,
    selectionDelegate: BaseMapViewSelectionDelegate?
  ) -> [BaseAnnotationViewModelProtocol] {
    compactMap { weatherInformationPersistencyModel -> WeatherStationMeteorologyInformationPreviewMapAnnotationViewModel? in
      guard let latitude = weatherInformationPersistencyModel.entity.coordinates.latitude,
            let longitude = weatherInformationPersistencyModel.entity.coordinates.longitude else {
        return nil
      }
      return WeatherStationMeteorologyInformationPreviewMapAnnotationViewModel(dependencies: WeatherStationMeteorologyInformationPreviewMapAnnotationViewModel.Dependencies(
        weatherInformationIdentity: weatherInformationPersistencyModel.identity,
        coordinate: CLLocationCoordinate2D(
          latitude: latitude,
          longitude: longitude
        ),
        weatherStationService: weatherStationService,
        weatherInformationService: weatherInformationService,
        preferencesService: preferencesService,
        annotationSelectionDelegate: selectionDelegate
      ))
    }
  }
}
