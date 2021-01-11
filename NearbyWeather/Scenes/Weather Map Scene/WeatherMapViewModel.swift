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

extension WeatherMapViewModel { // TODO : check which are needed
  struct Dependencies {
    let weatherInformationService: WeatherInformationPersistence & WeatherInformationUpdating
    let weatherStationService: WeatherStationBookmarkReading
    let userLocationService: UserLocationReading
    let preferencesService: WeatherMapPreferencePersistence & UnitSettingsPreferenceReading
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
  
  let onDidSelectFocusOnWeatherStationSubject = PublishSubject<CLLocation?>()
  let onDidSelectFocusOnUserLocationSubject = PublishSubject<Void>()
  
  // MARK: - Drivers
  
  lazy var preferredMapTypeDriver = preferredMapTypeObservable.asDriver(onErrorJustReturn: .standard)
  lazy var preferredAmountOfResultsDriver = preferredAmountOfResultsObservable.asDriver(onErrorJustReturn: .ten)
  lazy var focusOnWeatherStationDriver = onDidSelectFocusOnWeatherStationSubject.asDriver(onErrorJustReturn: nil)
  lazy var focusOnUserLocationDriver: Driver<CLLocation?> = { [dependencies] in
    onDidSelectFocusOnUserLocationSubject
      .asObservable()
      .flatMapLatest { _ in dependencies.userLocationService.createGetCurrentLocationOptionalObservable() }
      .asDriver(onErrorJustReturn: nil)
  }()
  
  // MARK: - Observables
  
  private lazy var preferredMapTypeObservable: Observable<MapTypeValue> = { [dependencies] in
    dependencies
      .preferencesService
      .createGetMapTypeOptionObservable()
      .map { $0.value }
      .share(replay: 1)
  }()
  
  private lazy var preferredAmountOfResultsObservable: Observable<AmountOfResultsValue>  = { [dependencies] in
    dependencies
      .preferencesService
      .createGetAmountOfNearbyResultsOptionObservable()
      .map { $0.value }
      .share(replay: 1)
  }()
  
  // MARK: - Initialization
  
  required init(dependencies: Dependencies) {
    self.dependencies = dependencies
    super.init()
    
    mapDelegate = WeatherMapMapViewDelegate(annotationSelectionDelegate: self)
  }
  
  // MARK: - Functions
  
  func observeEvents() {
    observeDataSource()
    observeUserTapEvents()
  }
}

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
        resultSelector: { [dependencies] weatherInformationList, _ in
          weatherInformationList.mapToWeatherMapAnnotationViewModel(dependencies: dependencies, isBookmark: false, selectionDelegate: self)
        }
      )
      .catchErrorJustReturn([])
      .share(replay: 1)
    
    let bookmarkedMapItemsObservable = Observable
      .combineLatest(
        dependencies.weatherInformationService.createGetBookmarkedWeatherInformationListObservable(),
        apiKeyValidObservable,
        resultSelector: { [dependencies] weatherInformationList, _ in
          weatherInformationList.mapToWeatherMapAnnotationViewModel(dependencies: dependencies, isBookmark: false, selectionDelegate: self)
        }
      )
      .catchErrorJustReturn([])
      .share(replay: 1)
    
    Observable
      .combineLatest(
        nearbyMapItemsObservable,
        bookmarkedMapItemsObservable,
        resultSelector: { nearbyAnnotations, bookmarkedAnnotations in
          var mutableNearbyAnnotations = nearbyAnnotations
          
          mutableNearbyAnnotations.removeAll { nearbyAnnotation -> Bool in
            bookmarkedAnnotations.contains { bookmarkedAnnotation -> Bool in
              let nearbyIdentifier = (nearbyAnnotation as? WeatherMapAnnotationViewModel)?.weatherInformationIdentity.identifier
              let bookmarkedIdentifier = (bookmarkedAnnotation as? WeatherMapAnnotationViewModel)?.weatherInformationIdentity.identifier
              return nearbyIdentifier == bookmarkedIdentifier
            }
          }
          
          return WeatherMapAnnotationData(
            annotationViewReuseIdentifier: WeatherMapAnnotationView.reuseIdentifier,
            annotationItems: mutableNearbyAnnotations + bookmarkedAnnotations
          )
        }
      )
      .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
      .bind { [weak mapDelegate] in mapDelegate?.dataSource.accept($0) }
      .disposed(by: disposeBag)
  }
  
  func observeUserTapEvents() {
    let preferredMapTypeObservable = dependencies
      .preferencesService
      .createGetMapTypeOptionObservable()
      .map { $0.value }
      .share(replay: 1)
    
    onDidTapMapTypeBarButtonSubject
      .flatMapLatest { [unowned preferredMapTypeObservable] in preferredMapTypeObservable }
      .subscribe(onNext: { [weak steps] preferredMapType in
        steps?.accept(MapStep.changeMapTypeAlert(currentSelectedOptionValue: preferredMapType))
      })
      .disposed(by: disposeBag)
    
    onDidTapAmountOfResultsBarButtonSubject
      .flatMapLatest { [unowned preferredAmountOfResultsObservable] in preferredAmountOfResultsObservable }
      .subscribe(onNext: { [weak steps] preferredAmountOfResults in
        steps?.accept(MapStep.changeAmountOfResultsAlert(currentSelectedOptionValue: preferredAmountOfResults))
      })
      .disposed(by: disposeBag)
    
    onDidTapFocusOnLocationBarButtonSubject
      .subscribe(onNext: { [weak steps] _ in
        steps?.accept(MapStep.focusOnLocationAlert(selectionDelegate: self))
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - Delegate Extensions

extension WeatherMapViewModel: BaseMapViewSelectionDelegate {
  
  func didSelectView(for annotationViewModel: BaseAnnotationViewModelProtocol) {
    guard let annotationViewModel = annotationViewModel as? WeatherMapAnnotationViewModel else {
      return
    }
    _ = Observable
      .combineLatest(
        Observable.just(annotationViewModel.weatherInformationIdentity),
        Observable.just(annotationViewModel.isBookmark),
        resultSelector: { weatherInformationIdentity, isBookmark -> MapStep in
          MapStep.weatherDetails2(
            identity: weatherInformationIdentity,
            isBookmark: isBookmark
          )
        }
      )
      .take(1)
      .asSingle()
      .subscribe(onSuccess: steps.accept)
  }
}

extension WeatherMapViewModel: FocusOnLocationSelectionAlertDelegate {
  
  func didSelectFocusOnLocationOption(_ option: FocusOnLocationOption) {
    switch option {
    case .userLocation:
      onDidSelectFocusOnUserLocationSubject.onNext(())
    case let .weatherStation(location):
      onDidSelectFocusOnWeatherStationSubject.onNext(location)
    }
  }
}

// MARK: - Helper Extensions

private extension Array where Element == PersistencyModel<WeatherInformationDTO> {
  
  func mapToWeatherMapAnnotationViewModel(dependencies: WeatherMapViewModel.Dependencies, isBookmark: Bool, selectionDelegate: BaseMapViewSelectionDelegate) -> [BaseAnnotationViewModelProtocol] {
    compactMap { weatherInformationPersistencyModel -> WeatherMapAnnotationViewModel? in
      guard let latitude = weatherInformationPersistencyModel.entity.coordinates.latitude,
            let longitude = weatherInformationPersistencyModel.entity.coordinates.longitude else {
        return nil
      }
      return WeatherMapAnnotationViewModel(dependencies: WeatherMapAnnotationViewModel.Dependencies(
        weatherInformationIdentity: weatherInformationPersistencyModel.identity,
        isBookmark: isBookmark,
        coordinate: CLLocationCoordinate2D(
          latitude: latitude,
          longitude: longitude
        ),
        weatherInformationService: dependencies.weatherInformationService,
        preferencesService: dependencies.preferencesService,
        annotationSelectionDelegate: selectionDelegate
      ))
    }
  }
}
