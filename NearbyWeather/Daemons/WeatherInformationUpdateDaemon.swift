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

final class WeatherInformationUpdateDaemon: Daemon {
  
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
    self.observeBookmarkedStationsChanges()
    self.observeApiKeyChanges()
    self.observeAmountOfNearbyResultsPreferenceChanges()
    self.observeLocationAccessAuthorization()
    self.observeAppDidBecomeActive()
  }
  
  func stopObservations() {
    disposeBag = DisposeBag()
  }
}

// MARK: - Observations

private extension WeatherInformationUpdateDaemon {
  
  func observeBookmarkedStationsChanges() {
    dependencies.weatherStationService
      .createGetBookmarkedStationsObservable()
      .distinctUntilChanged()
      .catch { _ -> Observable<[WeatherStationDTO]> in Observable.just([]) }
      .flatMapLatest { [dependencies] _ -> Observable<Void> in
        dependencies.weatherInformationService
          .createUpdateBookmarkedWeatherInformationCompletable()
          .asObservable()
          .map { _ in () }
      }
      .subscribe()
      .disposed(by: disposeBag)
  }
  
  // TODO: this completes prematurely when invalid api key was saved
  func observeApiKeyChanges() {
    dependencies.apiKeyService
      .createGetApiKeyObservable()
      .map { apiKey -> String? in apiKey } // convert to optional
      .distinctUntilChanged()
      .asInfallible(onErrorRecover: { error in
        if error as? ApiKeyService.DomainError != nil {
          return Infallible.just(nil) // key is missing or invalid -> return nil to delete previously downloaded weather information
        }
        return Infallible.just("") // some other error occured -> do not return nil to delete previously downloaded weather information
      })
      .asObservable()
      .do(onNext: { [dependencies] apiKey in
        // key is nil (invalid or missing) -> signal to delete previously downloaded weather information
        guard let apiKey = apiKey else {
          _ = Completable.zip([
            dependencies.weatherInformationService.createDeleteBookmarkedWeatherInformationListCompletable(),
            dependencies.weatherInformationService.createDeleteNearbyWeatherInformationListCompletable()
          ])
            .subscribe()
          return
        }
        // key is empty (some unrelated error occured) -> signal to do nothing
        if apiKey.isEmpty {
          return
        }
        // key exists (was changed, is valid) -> signal to update weather information
        _ = Completable.zip([
          dependencies.weatherInformationService.createUpdateBookmarkedWeatherInformationCompletable(),
          dependencies.weatherInformationService.createUpdateNearbyWeatherInformationCompletable()
        ])
          .subscribe()
      })
      .subscribe()
      .disposed(by: disposeBag)
  }
  
  func observeAmountOfNearbyResultsPreferenceChanges() {
    dependencies.preferencesService
      .createGetAmountOfNearbyResultsOptionObservable()
      .flatMapLatest { [dependencies] _ in dependencies.weatherInformationService.createUpdateNearbyWeatherInformationCompletable().asObservable().map { _ in () } }
      .subscribe()
      .disposed(by: disposeBag)
  }
  
  func observeLocationAccessAuthorization() {
    dependencies.userLocationService
      .createGetLocationAuthorizationStatusObservable()
      .filter { !($0?.authorizationStatusIsSufficient ?? false) } // keep going when not authorized
      .flatMapLatest { [dependencies] _ -> Observable<Void> in
        dependencies.weatherInformationService
          .createDeleteNearbyWeatherInformationListCompletable()
          .asObservable()
          .map { _ in () }
      }
      .subscribe()
      .disposed(by: disposeBag)
  }
  
  func observeAppDidBecomeActive() {
    // TODO
  }
}
