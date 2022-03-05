//
//  WeatherStationCurrentInformationWindCellModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 15.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import UIKit

struct WeatherStationMeteorologyDetailsWindCellModel {
  
  let windSpeedString: String?
  let windDirectionString: String?
  let windDirectionRotationAngle: CGFloat?
  
  init(
    windSpeedString: String? = nil,
    windDirectionString: String? = nil,
    windDirectionRotationAngle: CGFloat? = nil
  ) {
    self.windSpeedString = windSpeedString
    self.windDirectionString = windDirectionString
    self.windDirectionRotationAngle = windDirectionRotationAngle
  }
  
  init(
    windSpeed: Double,
    windDirectionDegrees: Double,
    dimensionaUnitsPreference: DimensionalUnitsOption
  ) {
    self.init(
      windSpeedString: ConversionWorker.windspeedDescriptor(
        forDistanceSpeedUnit: dimensionaUnitsPreference,
        forWindspeed: windSpeed
      ),
      windDirectionString: ConversionWorker.windDirectionDescriptor(forWindDirection: windDirectionDegrees),
      windDirectionRotationAngle: CGFloat(windDirectionDegrees)*0.0174532925199 // convert to radians
    )
  }
}
