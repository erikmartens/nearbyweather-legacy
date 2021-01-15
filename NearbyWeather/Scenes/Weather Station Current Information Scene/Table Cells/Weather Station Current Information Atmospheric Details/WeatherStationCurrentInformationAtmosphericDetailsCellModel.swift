//
//  WeatherStationCurrentInformationAtmosphericDetailsCellModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 15.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import Foundation

struct WeatherStationCurrentInformationAtmosphericDetailsCellModel { // swiftlint:disable:this type_name
  
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
      cloudCoverageString: String
        .begin(with: cloudCoverage)
        .append(contentsOf: "%", delimiter: .none, emptyIfPredecessorWasEmpty: true)
        .ifEmpty(justReturn: nil),
      humidityString: String
        .begin(with: humidity)
        .append(contentsOf: "%", delimiter: .none, emptyIfPredecessorWasEmpty: true)
        .ifEmpty(justReturn: nil),
      airPressureString: String
        .begin(with: pressurePsi)
        .append(contentsOf: "hpa", delimiter: .none, emptyIfPredecessorWasEmpty: true)
        .ifEmpty(justReturn: nil)
    )
  }
}
