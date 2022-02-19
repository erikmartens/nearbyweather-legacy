//
//  UserLocationUpdateDaemon.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 18.02.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxOptional
import CoreLocation

// MARK: - Dependencies

extension UserLocationUpdateDaemon {
  struct Dependencies {
    var userLocationService: UserLocationWriting & UserLocationPermissionWriting
  }
}

// MARK: - Class Definition

final class UserLocationUpdateDaemon: NSObject, Daemon {
  
  // MARK: - Assets
  
  private var disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  private let locationManager: CLLocationManager
  
  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
    locationManager = CLLocationManager()
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
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
    locationManager.delegate = self
    guard locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways else {
      return
    }
    locationManager.startUpdatingLocation()
  }
  
  func stopObservations() {
    locationManager.stopUpdatingLocation()
    disposeBag = DisposeBag()
  }
}

// MARK: - Delegate Extensions

extension UserLocationUpdateDaemon: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    
    _ = dependencies.userLocationService
      .createSaveLocationAuthorizationStatusCompletable(
        UserLocationAuthorizationStatus(authorizationStatus: UserLocationAuthorizationStatusOption(clAuthorizationStatus: status))
      )
    
    if status == .authorizedWhenInUse || status == .authorizedAlways {
      locationManager.startUpdatingLocation()
      return
    }
    _ = dependencies.userLocationService
      .createDeleteUserLocationCompletable()
      .subscribe()
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    _ = dependencies.userLocationService
      .createSaveUserLocationCompletable(location: locations.first!)
      .subscribe()
  }
}
