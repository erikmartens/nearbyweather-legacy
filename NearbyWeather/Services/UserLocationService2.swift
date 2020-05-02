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

final class UserLocationService2 {
  
  // MARK: - Properties
  
  private let locationManager: CLLocationManager
  
  // MARK: - Initialization
  
  init() {
    locationManager = CLLocationManager()
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
  }
}

extension UserLocationService2 {
  
  private static func authorizationStatusIsSufficient(_ authorizationStatus: CLAuthorizationStatus) -> Bool {
    switch authorizationStatus {
    case .notDetermined, .restricted, .denied:
      return false
    case .authorizedWhenInUse, .authorizedAlways:
      return true
    @unknown default:
      return false
    }
  }
  
  func createDidUpdateLocationObservable() -> Observable<CLLocation> {
    locationManager.rx
      .location
      .errorOnNil()
      .do(onSubscribe: { [locationManager] in locationManager.startUpdatingLocation() },
          onDispose: { [locationManager] in locationManager.stopUpdatingLocation() })
  }
  
  func createCurrentAuthorizationStatusSingle() -> Single<Bool> {
    Single
      .just(CLLocationManager.authorizationStatus())
      .map { Self.authorizationStatusIsSufficient($0) }
  }
  
  func createDidChangeAuthorizationObservable() -> Observable<Bool> {
    locationManager.rx
      .didChangeAuthorization
      .map { $0.status }
      .map { Self.authorizationStatusIsSufficient($0) }
  }
}
