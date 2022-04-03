//
//  WeatherStationCurrentInformationMapCellModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 16.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import Foundation

struct WeatherStationMeteorologyDetailsMapCellModel {
  
  let preferredMapTypeOption: MapTypeOption?
  
  init(
    preferredMapTypeOption: MapTypeOption? = nil
  ) {
    self.preferredMapTypeOption = preferredMapTypeOption
  }
}
