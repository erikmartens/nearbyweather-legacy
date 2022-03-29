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
  
  let onDidSelectFocusOnWeatherStationSubject = PublishSubject<CLLocation?>()
  let onDidSelectFocusOnUserLocationSubject = PublishSubject<Void>()
  
  // MARK: - Drivers
  
  lazy var preferredMapTypeDriver = preferredMapTypeObservable.asDriver(onErrorJustReturn: .standard)
  lazy var preferredAmountOfResultsDriver = preferredAmountOfResultsObservable.asDriver(onErrorJustReturn: .ten)
  lazy var focusOnWeatherStationDriver = onDidSelectFocusOnWeatherStationSubject.asDriver(onErrorJustReturn: nil)
  lazy var focusOnUserLocationDriver: Driver<CLLocation?> = onDidSelectFocusOnUserLocationSubject
    .asObservable()
    .flatMapLatest { [unowned self] _ in dependencies.userLocationService.createGetUserLocationObservable().take(1) }
    .map { location -> CLLocation? in location }
    .asDriver(onErrorJustReturn: nil)
  
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
    
    mapDelegate = WeatherMapMapViewDelegate(annotationSelectionDelegate: self, annotationViewType: WeatherMapAnnotationView.self)
  }
  
  deinit {
    printDebugMessage(
      domain: String(describing: self),
      message: "was deinitialized",
      type: .info
    )
  }
  
  func viewWillAppear() {
    _ = dependencies.userLocationService
      .createGetUserLocationObservable()
      .take(1)
      .asSingle()
      .subscribe(onSuccess: { [unowned self] _ in onDidSelectFocusOnUserLocationSubject.onNext(()) })
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
      .bind { [weak mapDelegate] in mapDelegate?.dataSource.accept($0) }
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
    guard let annotationViewModel = annotationViewModel as? WeatherMapAnnotationViewModel else {
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
      onDidSelectFocusOnUserLocationSubject.onNext(())
    case let .weatherStation(location):
      onDidSelectFocusOnWeatherStationSubject.onNext(location)
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
