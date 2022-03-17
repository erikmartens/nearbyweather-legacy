//
//  WeatherInformationUpdateDaemon.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 13.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxOptional

// MARK: - Dependencies

extension WeatherInformationUpdateDaemon {
  struct Dependencies { // TODO: create protocols for all
    var apiKeyService: ApiKeyService
    var preferencesService: PreferencesService
    var userLocationService: UserLocationService
    var weatherStationService: WeatherStationService
    var weatherInformationService: WeatherInformationService
  }
}

// MARK: - Class Definition

final class WeatherInformationUpdateDaemon: NSObject, Daemon {
  
  // MARK: - Assets
  
  private var disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  // MARK: - Observables
  
  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }
  
  deinit {
    printDebugMessage(
      domain: String(describing: self),
      message: "was deinitialized",
      type: .info
    )
  }
  
  // MARK: - Functions
  
  func startObservations() {
    observeBookmarkedStationsChanges()
    observeAmountOfNearbyResultsPreferenceChanges()
    observeLocationAccessAuthorization()
    observeAppDidBecomeActive()
  }
  
  func stopObservations() {
    disposeBag = DisposeBag()
  }
}

// MARK: - Observations

private extension WeatherInformationUpdateDaemon {
  
  // TODO: inefficient -> only load information for added stations and delete information for removed stations
  func observeBookmarkedStationsChanges() {
    dependencies.weatherStationService
      .createGetBookmarkedStationsObservable()
      .distinctUntilChanged()
      .catch { _ -> Observable<[WeatherStationDTO]> in Observable.just([]) }
      .do(onNext: { [dependencies] _ in
        _ = dependencies.weatherInformationService
          .createUpdateBookmarkedWeatherInformationCompletable()
          .subscribe()
      })
      .subscribe()
      .disposed(by: disposeBag)
  }
  
  func observeAmountOfNearbyResultsPreferenceChanges() {
    dependencies.preferencesService
      .createGetAmountOfNearbyResultsOptionObservable()
      .distinctUntilChanged()
      .do(onNext: { [dependencies] _ in
        _ = dependencies.weatherInformationService
          .createUpdateNearbyWeatherInformationCompletable()
          .subscribe()
      })
      .subscribe()
      .disposed(by: disposeBag)
  }
  
  func observeLocationAccessAuthorization() {
    dependencies.userLocationService
      .createGetLocationAuthorizationStatusObservable()
      .distinctUntilChanged()
      .filter { !($0?.authorizationStatusIsSufficient ?? false) } // keep going when not authorized
      .do(onNext: { [dependencies] _ in
        _ = dependencies.weatherInformationService
          .createDeleteNearbyWeatherInformationListCompletable()
          .subscribe()
      })
      .subscribe()
      .disposed(by: disposeBag)
  }
  
  func observeAppDidBecomeActive() {
    // TODO
  }
}
