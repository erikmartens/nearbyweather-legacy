//
//  WeatherInformationUpdateDaemon.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 13.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa
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
  
  private let appDidBecomeActiveRelay = PublishRelay<Void>()
  
  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
    super.init()
    NotificationCenter.default.addObserver(self, selector: #selector(notifyAppDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
    
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
  
  func observeBookmarkedStationsChanges() {
    let updateBookmarkedWeatherInformationObservable = Observable
      .combineLatest(
        dependencies.weatherInformationService.createGetBookmarkedWeatherInformationListObservable().map { $0.map { $0.identity.identifier } },
        dependencies.weatherStationService.createGetBookmarkedStationsObservable().map { $0.compactMap { $0.identifier} }.map { $0.map { String($0) } },
        resultSelector: { existingWeatherInformationIdentifiers, bookmarkedWeatherInformationIdentifiers -> ([String], [String]) in
          var toBeDeletedWeatherInformationIdentifiers: [String] = []
          var toBeAddedWeatherInformationIdentifiers: [String] = []
          
          existingWeatherInformationIdentifiers.forEach { exisitingIdentifier in
            if !bookmarkedWeatherInformationIdentifiers.contains(exisitingIdentifier) {
              toBeDeletedWeatherInformationIdentifiers.append(exisitingIdentifier)
            }
          }
          
          bookmarkedWeatherInformationIdentifiers.forEach { bookmarkedIdentifier in
            if !existingWeatherInformationIdentifiers.contains(bookmarkedIdentifier) {
              toBeAddedWeatherInformationIdentifiers.append(bookmarkedIdentifier)
            }
          }
          
          return (toBeDeletedWeatherInformationIdentifiers, toBeAddedWeatherInformationIdentifiers)
        }
      )
      .flatMapLatest { [unowned self] result in
        Completable
          .zip(
            result.0.map { dependencies.weatherInformationService.createRemoveBookmarkedWeatherInformationItemCompletable(for: $0) }
            + result.1.map { dependencies.weatherInformationService.createUpdateBookmarkedWeatherInformationCompletable(forStationWith: Int($0)) }
          )
          .asObservable()
          .materialize()
      }
    
    // only start observing this after the app became active
    appDidBecomeActiveRelay
      .asObservable()
      .flatMapLatest { _ in updateBookmarkedWeatherInformationObservable }
      .subscribe()
      .disposed(by: disposeBag)
  }
  
  func observeAmountOfNearbyResultsPreferenceChanges() {
    // only start observing this after the app became active
    appDidBecomeActiveRelay
      .asObservable()
      .flatMapLatest { [unowned self] _ in
        dependencies.preferencesService
          .createGetAmountOfNearbyResultsOptionObservable()
          .distinctUntilChanged()
          .flatMapLatest { [unowned self] _ in
            dependencies.weatherInformationService
              .createUpdateNearbyWeatherInformationCompletable()
              .asObservable()
              .materialize()
          }
      }
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
    appDidBecomeActiveRelay
      .asObservable()
      .flatMapLatest { [unowned self] _ in
        dependencies.preferencesService
          .createGetRefreshOnAppStartOptionObservable()
          .take(1)
          .asSingle()
          .flatMapCompletable { [unowned self] refreshOnAppStartOption -> Completable in
            guard refreshOnAppStartOption.value == .yes else {
              return Completable.emptyCompletable
            }
            return Completable.zip([
              dependencies.weatherInformationService.createUpdateBookmarkedWeatherInformationCompletable(),
              dependencies.weatherInformationService.createUpdateNearbyWeatherInformationCompletable()
            ])
          }
          .asObservable()
          .materialize()
      }
      .subscribe()
      .disposed(by: disposeBag)
  }
}

// MARK: - Helpers

fileprivate extension WeatherInformationUpdateDaemon {
  
  @objc func notifyAppDidBecomeActive() {
    appDidBecomeActiveRelay.accept(())
  }
}
