//
//  WeatherStationCurrentInformationAtmosphericDetailsCellModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 15.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import Foundation

struct WeatherStationMeteorologyDetailsAtmosphericDetailsCellModel { // swiftlint:disable:this type_name
  
  let cloudCoverageString: String?
  let humidityString: String?
  let airPressureString: String?
  
  init(
    cloudCoverageString: String? = nil,
    humidityString: String? = nil,
    airPressureString: String? = nil
  ) {
    self.cloudCoverageString = cloudCoverageString
    self.humidityString = humidityString
    self.airPressureString = airPressureString
  }
  
  init(
    cloudCoverage: Double,
    humidity: Double,
    pressurePsi: Double
  ) {
    self.init(
      cloudCoverageString: MeteorologyInformationConversionWorker.cloudCoverageDescriptor(for: cloudCoverage),
      humidityString: MeteorologyInformationConversionWorker.humidityDescriptor(for: humidity),
      airPressureString: MeteorologyInformationConversionWorker.airPressureDescriptor(for: pressurePsi)
    )
  }
}
