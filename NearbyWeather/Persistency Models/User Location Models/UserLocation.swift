//
//  UserLocation.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.02.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import Foundation

struct UserLocation: Codable, Equatable {
  
  var latitude: Double
  var longitude: Double
  
  init(latitude: Double, longitude: Double) {
    self.latitude = latitude
    self.longitude = longitude
  }
}
