//
//  WeatherStationCurrentInformationMapCellModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 16.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import Foundation

struct WeatherStationCurrentInformationMapCellModel {
  
  let preferredMapTypeOption: MapTypeOption?
  let coordinatesString: String?
  let distanceString: String?
  
  init(
    preferredMapTypeOption: MapTypeOption? = nil,
    coordinatesString: String? = nil,
    distanceString: String? = nil
  ) {
    self.preferredMapTypeOption = preferredMapTypeOption
    self.coordinatesString = coordinatesString
    self.distanceString = distanceString
  }
}
