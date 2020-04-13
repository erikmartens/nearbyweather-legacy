//
//  Constants+Mocks.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 30.01.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

extension Constants {
  enum Mocks {}
}

extension Constants.Mocks {
  
  enum WeatherStationDTOs {
    static let kDefaultBookmarkedLocation = WeatherStationDTO(
      identifier: 5341145,
      name: "Cupertino",
      state: "CA",
      country: "US",
      coordinates: Coordinates(latitude: 37.323002, longitude: -122.032181)
    )
  }
}
