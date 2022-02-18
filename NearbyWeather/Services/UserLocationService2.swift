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
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
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
//    locationManager.rx
//      .didChangeAuthorization
//      .map { $0.status }
//      .startWith(locationManager.authorizationStatus)
//      .map { Self.authorizationStatusIsSufficient($0) }
    Observable.just(true).share(replay: 1)
  }
  
  func createGetCurrentLocationObservable() -> Observable<CLLocation> {
//    createGetAuthorizationStatusObservable()
//      .flatMapLatest { [unowned locationManager] authorized -> Observable<CLLocation?> in
//        guard authorized else {
//          throw UserLocationService2.DomainError.locationAuthorizationError
//        }
//        return locationManager.rx.location
//      }
//      .map { location -> CLLocation in
//        guard let location = location else {
//          throw UserLocationService2.DomainError.locationUndeterminableError
//        }
//        return location
//      }
//      .do(onSubscribe: { [locationManager] in locationManager.startUpdatingLocation() },
//          onDispose: { [locationManager] in locationManager.stopUpdatingLocation() })
    Observable.just(CLLocation(latitude: 49.37516443130754, longitude: 8.150853842090196)).share(replay: 1)
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
