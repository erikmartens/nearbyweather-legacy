//
//  WeatherInformationUpdateDaemon.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 13.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxOptional
import RxAlamofire

// MARK: - Dependencies

extension WeatherInformationUpdateDaemon {
  struct Dependencies { // TODO: create protocols for all
    weak var apiKeyService: ApiKeyService2?
    weak var userLocationService: UserLocationService2?
    weak var weatherStationService: WeatherStationService2?
    weak var weatherInformationService: WeatherInformationService2?
  }
}

// MARK: - Class Definition

final class WeatherInformationUpdateDaemon {
  
  // MARK: - Assets
  
  let disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
    startObservations()
  }
  
  // MARK: - Functions
  
  private func startObservations() {
    observeBookmarkedStationsChanges()
    observeApiKeyChanges()
    observeLocationAccessAuthorization()
  }
}

// MARK: - Observations

private extension WeatherInformationUpdateDaemon {
  
  // TODO: listen to application became active for refreshing
  
  func observeBookmarkedStationsChanges() {
    guard let weatherStationService = dependencies.weatherStationService,
          let weatherInformationService = dependencies.weatherInformationService else {
      return // TODO: error logging
    }
    
    weatherStationService
      .createGetBookmarkedStationsObservable()
      .distinctUntilChanged()
      .catchError { _ -> Observable<[WeatherStationDTO]> in Observable.just([]) }
      .flatMapLatest { _ -> Observable<Void> in
        weatherInformationService
          .createUpdateBookmarkedWeatherInformationCompletable()
          .asObservable()
          .map { _ in () }
      }
      .subscribe()
      .disposed(by: disposeBag)
  }
  
  func observeApiKeyChanges() {
    guard let weatherInformationService = dependencies.weatherInformationService else {
      return // TODO: error logging
    }
    
    dependencies.apiKeyService?
      .createGetApiKeyObservable()
      .map { apiKey -> String? in apiKey }
      .distinctUntilChanged()
      .catchError { error -> Observable<String?> in
        if error as? ApiKeyService2.DomainError != nil {
          return Observable.just(nil) // key is missing or invalid -> return nil to delete previously downloaded weather information
        }
        return Observable.just("") // some other error occured -> do not return nil to delete previously downloaded weather information
      }
      .flatMapLatest { apiKey -> Observable<Void> in
        // key is nil (invalid or missing) -> signal to delete previously downloaded weather information
        guard let apiKey = apiKey else {
          return Completable.zip([
            weatherInformationService.createDeleteBookmarkedWeatherInformationListCompletable(),
            weatherInformationService.createDeleteNearbyWeatherInformationListCompletable()
          ])
          .asObservable()
          .map { _ in () }
        }
        // key is empty (some unrelated error occured) -> signal to do nothing
        if apiKey.isEmpty {
          return Observable.just(())
        }
        // key exist (was change, is valid) -> signal to update weather information
        return Completable.zip([
          weatherInformationService.createUpdateBookmarkedWeatherInformationCompletable(),
          weatherInformationService.createUpdateNearbyWeatherInformationCompletable()
        ])
        .asObservable()
        .map { _ in () }
      }
      .subscribe()
      .disposed(by: disposeBag)
  }
  
  func observeLocationAccessAuthorization() {
    guard let weatherInformationService = dependencies.weatherInformationService else {
      return // TODO: error logging
    }
    
    dependencies.userLocationService?
      .createGetAuthorizationStatusObservable()
      .filter { !$0 } // keep going when not authorized
      .flatMapLatest { _ -> Observable<Void> in
        weatherInformationService
          .createDeleteNearbyWeatherInformationListCompletable()
          .asObservable()
          .map { _ in () }
      }
      .subscribe()
      .disposed(by: disposeBag)
  }
}
