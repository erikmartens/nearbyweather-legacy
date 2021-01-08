//
//  UserLocationService2.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 30.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import CoreLocation
import RxSwift
import RxCoreLocation

// MARK: - Domain-Specific Errors

extension UserLocationService2 {
  enum DomainError: String, Error {
    var domain: String { "UserLocationService" }
    
    case locationAuthorizationError = "Trying access the user location, but sufficient authorization was not granted."
    case locationUndeterminableError = "Trying access the user location, but it could not be determined."
  }
}

// MARK: - Class Definition

final class UserLocationService2 {
  
  // MARK: - Properties
  
  private let locationManager: CLLocationManager
  
  // MARK: - Initialization
  
  init() {
    locationManager = CLLocationManager()
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
  }
}

// MARK: - Location Observing

protocol LocationObserving {
  func createDidUpdateLocationObservable() -> Observable<CLLocation>
  func createAuthorizationStatusObservable() -> Observable<Bool>
  func createCurrentLocationObservable() -> Observable<CLLocation?>
}

extension UserLocationService2: LocationObserving {
  
  func createDidUpdateLocationObservable() -> Observable<CLLocation> {
    createAuthorizationStatusObservable()
      .map { if !$0 { throw DomainError.locationAuthorizationError } }
      .flatMapLatest { [locationManager] in
        locationManager.rx
          .location
          .errorOnNil()
      }
      .do(onSubscribe: { [locationManager] in locationManager.startUpdatingLocation() },
          onDispose: { [locationManager] in locationManager.stopUpdatingLocation() })
  }
  
  func createAuthorizationStatusObservable() -> Observable<Bool> {
    locationManager.rx
      .didChangeAuthorization
      .map { $0.status }
      .startWith(CLLocationManager.authorizationStatus())
      .map { Self.authorizationStatusIsSufficient($0) }
  }
  
  func createCurrentLocationObservable() -> Observable<CLLocation?> {
    Observable
      .combineLatest(
        locationManager.rx.location,
        createAuthorizationStatusObservable(),
        resultSelector: { currentLocation, currentAuthorizationStatus -> CLLocation? in
          guard currentAuthorizationStatus == true else {
            throw UserLocationService2.DomainError.locationAuthorizationError
          }
          guard let currentLocation = currentLocation else {
            throw UserLocationService2.DomainError.locationUndeterminableError
          }
          return currentLocation
        })
  }
}

// MARK: - Helpers

private extension UserLocationService2 {
  
  static func authorizationStatusIsSufficient(_ authorizationStatus: CLAuthorizationStatus) -> Bool {
    switch authorizationStatus {
    case .notDetermined, .restricted, .denied:
      return false
    case .authorizedWhenInUse, .authorizedAlways:
      return true
    @unknown default:
      return false
    }
  }
}
