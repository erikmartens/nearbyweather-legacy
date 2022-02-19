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
    var apiKeyService: ApiKeyService2
    var preferencesService: PreferencesService2
    var userLocationService: UserLocationService2
    var weatherStationService: WeatherStationService2
    var weatherInformationService: WeatherInformationService2
  }
}

// MARK: - Class Definition

final class WeatherInformationUpdateDaemon: Daemon {
  
  // MARK: - Assets
  
  private var disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  // MARK: - Observables
  
//  private var bookmarkedStationChangesObservable: Observable<Void>?
//  private var apiKeyChangesObservable: Observable<Void>?
//  private var amountOfNearbyResultsPreferenceChangesObservable: Observable<Void>?
//  private var locationAccessAuthorizationChangesObservable: Observable<Void>?
  
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
  
  func observeApiKeyChanges() {
    dependencies.apiKeyService
      .createGetApiKeyObservable()
      .map { apiKey -> String? in apiKey }
      .distinctUntilChanged()
      .catch { error -> Observable<String?> in
        if error as? ApiKeyService2.DomainError != nil {
          return Observable.just(nil) // key is missing or invalid -> return nil to delete previously downloaded weather information
        }
        return Observable.just("") // some other error occured -> do not return nil to delete previously downloaded weather information
      }
      .flatMapLatest { [dependencies] apiKey -> Observable<Void> in
        // key is nil (invalid or missing) -> signal to delete previously downloaded weather information
        guard let apiKey = apiKey else {
          return Completable.zip([
            dependencies.weatherInformationService.createDeleteBookmarkedWeatherInformationListCompletable(),
            dependencies.weatherInformationService.createDeleteNearbyWeatherInformationListCompletable()
          ])
          .asObservable()
          .map { _ in () }
        }
        // key is empty (some unrelated error occured) -> signal to do nothing
        if apiKey.isEmpty {
          return Observable.just(())
        }
        // key exists (was changed, is valid) -> signal to update weather information
        return Completable.zip([
          dependencies.weatherInformationService.createUpdateBookmarkedWeatherInformationCompletable(),
          dependencies.weatherInformationService.createUpdateNearbyWeatherInformationCompletable()
        ])
        .asObservable()
        .map { _ in () }
      }
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
