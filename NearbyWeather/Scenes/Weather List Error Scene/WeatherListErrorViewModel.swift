//
//  ListErrorViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 15.02.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa
import RxFlow
import CoreLocation

// MARK: - Domain Specific Types

extension WeatherListErrorViewModel {
  
  enum ListErrorType: Int {
    case network
    case apiKey
    case noData
    
    static func mapToErrorType(isApiKeyValid: Bool, isNetworkReachable: Bool) -> Self {
      if !isNetworkReachable {
        return .network
      } else if !isApiKeyValid {
        return .apiKey
      }
      return .noData
    }
    
    var title: String {
      switch self {
      case .network:
        return R.string.localizable.no_weather_data() // TODO: write different descriptions for different error
      case .apiKey:
        return R.string.localizable.no_weather_data()
      case .noData:
        return R.string.localizable.no_weather_data()
      }
    }
    
    var message: String {
      switch self {
      case .network:
        return R.string.localizable.no_data_description() // TODO: write different descriptions for different error
      case .apiKey:
        return R.string.localizable.no_data_description()
      case .noData:
        return R.string.localizable.no_data_description()
      }
    }
  }
}

// MARK: - Dependencies

extension WeatherListErrorViewModel {
  
  struct Dependencies {
    let apiKeyService: ApiKeyReading
    let weatherInformationService: WeatherInformationUpdating
    let networkReachabilityService: NetworkReachability
  }
}

// MARK: - Class Definition

final class WeatherListErrorViewModel: NSObject, Stepper, BaseViewModel {
  
  // MARK: - Routing
  
  let steps = PublishRelay<Step>()
  
  // MARK: - Assets
  
  private var disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  // MARK: - Events
  
  let onDidTapRefreshButtonSubject = PublishSubject<Void>()
  private let isRefreshingSubject = PublishSubject<Bool>()
  
  // MARK: - Drivers
  
  lazy var isRefreshingDriver = isRefreshingSubject.asDriver(onErrorJustReturn: false)
  lazy var errorTypeDriver: Driver<ListErrorType> = Observable
    .combineLatest(
      isApiKeyValidObservable,
      isNetworkReachableObservable,
      resultSelector: ListErrorType.mapToErrorType
    )
    .asDriver(onErrorJustReturn: .network)
  
  // MARK: - Observables
  
  private lazy var isApiKeyValidObservable: Observable<Bool> = { [dependencies] in
    dependencies.apiKeyService
      .createApiKeyIsValidObservable()
      .map { $0.isValid }
      .share(replay: 1)
  }()
  
  private lazy var isNetworkReachableObservable: Observable<Bool> = { [dependencies] in
    dependencies.networkReachabilityService
      .createIsNetworkReachableObservable()
      .share(replay: 1)
  }()
  
  // MARK: - Initialization
  
  required init(dependencies: Dependencies) {
    self.dependencies = dependencies
    super.init()
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
  
  func disregardEvents() {
    disposeBag = DisposeBag()
  }
}

// MARK: - Observations

extension WeatherListErrorViewModel {

  func observeDataSource() {
      // nothing to do
  }
  
  func observeUserTapEvents() {
    onDidTapRefreshButtonSubject
      .do(onNext: { [weak isRefreshingSubject] in isRefreshingSubject?.onNext(true) })
      .flatMapLatest { [weak isRefreshingSubject, dependencies] _ -> Observable<Void> in
        Completable
          .zip([dependencies.weatherInformationService.createUpdateNearbyWeatherInformationCompletable(),
                dependencies.weatherInformationService.createUpdateBookmarkedWeatherInformationCompletable()])
          .do(onCompleted: { isRefreshingSubject?.onNext(false) })
          .asObservable()
          .map { _ in () }
      }
      .subscribe()
      .disposed(by: disposeBag)
  }
}
