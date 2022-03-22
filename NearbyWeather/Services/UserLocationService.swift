//
//  UserLocationService.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 30.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import CoreLocation
import RxSwift
import RxCoreLocation

// MARK: - Domain-Specific Errors

extension UserLocationService {
  enum DomainError: String, Error {
    var domain: String { "UserLocationService" }
    
    case locationAuthorizationError = "Trying access the user location, but sufficient authorization was not granted."
    case locationUndeterminableError = "Trying access the user location, but it could not be determined."
  }
}

// MARK: - Persistency Keys

private extension UserLocationService {
  enum PersistencyKeys {
    case userLocation
    case authorizationStatus
    
    var collection: String {
      switch self {
      case .userLocation: return "/user_location/user_location/"
      case .authorizationStatus: return "/user_location/authorization_status/"
      }
    }
    
    var identifier: String {
      switch self {
      case .userLocation: return "default"
      case .authorizationStatus: return "default"
      }
    }
    
    var identity: PersistencyModelIdentity {
      PersistencyModelIdentity(collection: collection, identifier: identifier)
    }
  }
}

// MARK: - Dependencies

extension UserLocationService {
  struct Dependencies {
    let persistencyService: PersistencyProtocol
  }
}

// MARK: - Class Definition

final class UserLocationService {
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  private let locationManager: CLLocationManager
  
  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
    locationManager = CLLocationManager()
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
  }
}

// MARK: - User Location Permissions Requesting

protocol UserLocationPermissionRequesting {
  func requestWhenInUseLocationAccess() -> Completable
  func createSaveLocationAuthorizationStatusCompletable(_ authorizationStatus: UserLocationAuthorizationStatus) -> Completable
  func createGetLocationAuthorizationStatusObservable() -> Observable<UserLocationAuthorizationStatus?>
}

extension UserLocationService: UserLocationPermissionRequesting {
 
  func requestWhenInUseLocationAccess() -> Completable {
    Completable
      .create { handler in
        let locationManager = CLLocationManager()
        guard locationManager.authorizationStatus == .notDetermined else {
          handler(.completed)
          return Disposables.create()
        }
        locationManager.requestWhenInUseAuthorization()
        handler(.completed)
        return Disposables.create()
      }
  }
  
  func createSaveLocationAuthorizationStatusCompletable(_ authorizationStatus: UserLocationAuthorizationStatus) -> Completable {
    dependencies.persistencyService
      .saveResource(
        PersistencyModel(identity: PersistencyKeys.authorizationStatus.identity, entity: authorizationStatus),
        type: UserLocationAuthorizationStatus.self
      )
  }
  
  func createGetLocationAuthorizationStatusObservable() -> Observable<UserLocationAuthorizationStatus?> {
    dependencies.persistencyService
      .observeResource(
        with: PersistencyKeys.authorizationStatus.identity,
        type: UserLocationAuthorizationStatus.self
      )
      .map { $0?.entity }
  }
}

// MARK: - User Location Permissions Writing

protocol UserLocationPermissionWriting {
  func createSaveLocationAuthorizationStatusCompletable(_ authorizationStatus: UserLocationAuthorizationStatus) -> Completable
}

extension UserLocationService: UserLocationPermissionWriting {}

// MARK: - User Location Permissions Reading

protocol UserLocationPermissionReading {
  func createGetLocationAuthorizationStatusObservable() -> Observable<UserLocationAuthorizationStatus?>
}

extension UserLocationService: UserLocationPermissionReading {}

// MARK: - User Location Accessing

protocol UserLocationAccessing {
  
  func createDeleteUserLocationCompletable() -> Completable
  func createSaveUserLocationCompletable(location: CLLocation?) -> Completable
  func createGetUserLocationObservable() -> Observable<CLLocation?>
}

extension UserLocationService: UserLocationAccessing {
  
  func createDeleteUserLocationCompletable() -> Completable {
    dependencies.persistencyService.deleteResource(with: PersistencyKeys.userLocation.identity)
  }
  
  func createSaveUserLocationCompletable(location: CLLocation?) -> Completable {
    guard let location = location else {
      return Completable.create { handler in
        handler(.completed)
        return Disposables.create()
      }
    }
    return dependencies.persistencyService.saveResource(
      PersistencyModel(
        identity: PersistencyKeys.userLocation.identity,
        entity: UserLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
      ),
      type: UserLocation.self)
  }
  
  func createGetUserLocationObservable() -> Observable<CLLocation?> {
    dependencies.persistencyService
      .observeResource(with: PersistencyKeys.userLocation.identity, type: UserLocation.self)
      .map { userLocation in
        guard let userLocation = userLocation else {
          return nil
        }
        return CLLocation(latitude: userLocation.entity.latitude, longitude: userLocation.entity.longitude)
      }
  }
}

// MARK: - User Location Writing

protocol UserLocationWriting {
  func createDeleteUserLocationCompletable() -> Completable
  func createSaveUserLocationCompletable(location: CLLocation?) -> Completable
}

extension UserLocationService: UserLocationWriting {}

// MARK: - User Location Reading

protocol UserLocationReading {
  func createGetUserLocationObservable() -> Observable<CLLocation?>
}

extension UserLocationService: UserLocationReading {}

// MARK: - Helpers

extension UserLocationAuthorizationStatus {
  
  var authorizationStatusIsSufficient: Bool {
    switch self.authorizationStatus {
    case .undetermined, .systemRevoked, .userRevoked:
      return false
    case .authorizedWhileUsing, .authorizedAnytime:
      return true
    }
  }
}

extension CLAuthorizationStatus {
  
  var authorizationStatusIsSufficient: Bool {
    switch self {
    case .notDetermined, .restricted, .denied:
      return false
    case .authorizedWhenInUse, .authorizedAlways:
      return true
    @unknown default:
      return false
    }
  }
}
