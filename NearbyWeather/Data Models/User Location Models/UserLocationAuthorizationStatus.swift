//
//  UserLocationAuthorizationStatus.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.02.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import CoreLocation

enum UserLocationAuthorizationStatusOption: Int, Codable {
  case undetermined
  case systemRevoked
  case userRevoked
  case authorizedAnytime
  case authorizedWhileUsing
  
  init(clAuthorizationStatus: CLAuthorizationStatus) {
    switch clAuthorizationStatus {
    case .notDetermined: self = .undetermined
    case .restricted: self = .systemRevoked
    case .denied: self = .userRevoked
    case .authorizedAlways: self = .authorizedAnytime
    case .authorizedWhenInUse: self = .authorizedWhileUsing
    @unknown default: self = .userRevoked
    }
  }
  
  var clAuthorizationStatus: CLAuthorizationStatus {
    switch self {
    case .undetermined: return .notDetermined
    case .systemRevoked: return .restricted
    case .userRevoked: return .denied
    case .authorizedAnytime: return .authorizedAlways
    case .authorizedWhileUsing: return .authorizedWhenInUse
    }
  }
}

struct UserLocationAuthorizationStatus: Codable, Equatable {
  
 var authorizationStatus: UserLocationAuthorizationStatusOption
  
  init(authorizationStatus: UserLocationAuthorizationStatusOption) {
    self.authorizationStatus = authorizationStatus
  }
}
