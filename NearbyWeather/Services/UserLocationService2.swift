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

// MARK: - User Location Permissions Requesting

protocol UserLocationPermissionRequesting {
  func requestWhenImUseLocationAccess() -> Completable
}

extension UserLocationService2: UserLocationPermissionRequesting {
  
  func requestWhenImUseLocationAccess() -> Completable {
    guard locationManager.authorizationStatus == .notDetermined else {
      return Completable.create { handler in
        handler(.completed)
        return Disposables.create()
      }
    }
    
    return Observable<Void>
      .create { [unowned locationManager] subscriber in
        locationManager.requestWhenInUseAuthorization()
        subscriber.on(.next(()))
        return Disposables.create()
      }
      .flatMapLatest { [unowned locationManager] () in
        locationManager.rx
          .didChangeAuthorization
          .map { $0.status }
          .filter { $0 != .notDetermined }
      }
      .take(1)
      .asSingle()
      .asCompletable()
  }
}

// MARK: - User Location Accessing

protocol UserLocationAccessing {
  func createGetAuthorizationStatusObservable() -> Observable<Bool>
  func createGetCurrentLocationObservable() -> Observable<CLLocation>
}

extension UserLocationService2: UserLocationAccessing {
  
  func createGetAuthorizationStatusObservable() -> Observable<Bool> {
    locationManager.rx
      .didChangeAuthorization
      .map { $0.status }
      .startWith(locationManager.authorizationStatus)
      .map { Self.authorizationStatusIsSufficient($0) }
  }
  
  func createGetCurrentLocationObservable() -> Observable<CLLocation> {
    Observable
      .combineLatest(
        locationManager.rx.location,
        createGetAuthorizationStatusObservable(),
        resultSelector: { currentLocation, currentAuthorizationStatus -> CLLocation in
          guard currentAuthorizationStatus == true else {
            throw UserLocationService2.DomainError.locationAuthorizationError
          }
          guard let currentLocation = currentLocation else {
            throw UserLocationService2.DomainError.locationUndeterminableError
          }
          return currentLocation
        }
      )
      .do(onSubscribe: { [locationManager] in locationManager.startUpdatingLocation() },
          onDispose: { [locationManager] in locationManager.stopUpdatingLocation() })
  }
}

// MARK: - User Location Reading

protocol UserLocationReading {
  func createGetCurrentLocationObservable() -> Observable<CLLocation>
}

extension UserLocationService2: UserLocationReading {}

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
