//
//  ListWeatherInformationTableCellModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

struct ListWeatherInformationTableCellModel {
  let weatherConditionCode: Int?
  let temperature: Double?
  let cloudCoverage: Double?
  let humidity: Double?
  let windspeed: Double?
  
  init(
    weatherConditionCode: Int? = nil,
    temperature: Double? = nil,
    cloudCoverage: Double? = nil,
    humidity: Double? = nil,
    windspeed: Double? = nil
  ) {
    self.weatherConditionCode = weatherConditionCode
    self.temperature = temperature
    self.cloudCoverage = cloudCoverage
    self.humidity = humidity
    self.windspeed = windspeed
  }
}
