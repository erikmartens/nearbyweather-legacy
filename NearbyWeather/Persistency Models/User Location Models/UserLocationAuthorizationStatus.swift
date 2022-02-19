//
//  UserLocationAuthorizationStatus.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.02.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import Foundation

enum UserLocationAuthorizationStatusOption: Int, Codable {
  case undetermined
  case systemRevoked
  case userRevoked
  case authorizedAnytime
  case authorizedWhileUsing
}

struct UserLocationAuthorizationStatus: Codable, Equatable {
  
 var authorizationStatus: UserLocationAuthorizationStatusOption
  
  init(authorizationStatus: UserLocationAuthorizationStatusOption) {
    self.authorizationStatus = authorizationStatus
  }
}
