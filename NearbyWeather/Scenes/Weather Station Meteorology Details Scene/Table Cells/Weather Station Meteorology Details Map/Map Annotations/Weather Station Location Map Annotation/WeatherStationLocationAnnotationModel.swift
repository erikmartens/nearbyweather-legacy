//
//  WeatherStationLocationAnnotationModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 01.04.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import MapKit

struct WeatherStationLocationAnnotationModel {
  let stationSymbol: UIImage?
  let tintColor: UIColor?
  let backgroundColor: UIColor?
  
  init(
    stationSymbol: UIImage? = nil,
    tintColor: UIColor? = nil,
    backgroundColor: UIColor? = nil
  ) {
    self.stationSymbol = stationSymbol
    self.tintColor = tintColor
    self.backgroundColor = backgroundColor
  }
}
