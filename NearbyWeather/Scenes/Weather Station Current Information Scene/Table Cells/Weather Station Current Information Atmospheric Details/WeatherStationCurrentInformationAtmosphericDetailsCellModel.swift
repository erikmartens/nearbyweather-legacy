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
    cloudCoverageDTO: WeatherInformationDTO.CloudCoverageDTO,
    atmosphericInformationDTO: WeatherInformationDTO.AtmosphericInformationDTO
  ) {
    self.init(
      cloudCoverageString: String
        .begin(with: cloudCoverageDTO.coverage)
        .append(contentsOf: "%", delimiter: .none, emptyIfPredecessorWasEmpty: true)
        .ifEmpty(justReturn: nil),
      humidityString: String
        .begin(with: atmosphericInformationDTO.humidity)
        .append(contentsOf: "%", delimiter: .none, emptyIfPredecessorWasEmpty: true)
        .ifEmpty(justReturn: nil),
      airPressureString: String
        .begin(with: atmosphericInformationDTO.pressurePsi)
        .append(contentsOf: "hpa", delimiter: .none, emptyIfPredecessorWasEmpty: true)
        .ifEmpty(justReturn: nil)
    )
  }
}
