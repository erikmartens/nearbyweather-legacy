//
//  ListWeatherInformationTableCellModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit

struct WeatherListInformationTableViewCellModel {
  let weatherConditionSymbol: String?
  let placeName: String?
  let temperature: String?
  let cloudCoverage: String?
  let humidity: String?
  let windspeed: String?
  let backgroundColor: UIColor?
  let borderColor: UIColor?
  
  init(
    weatherConditionSymbol: String? = nil,
    placeName: String? =  nil,
    temperature: String? = nil,
    cloudCoverage: String? = nil,
    humidity: String? = nil,
    windspeed: String? = nil,
    backgroundColor: UIColor? = nil,
    borderColor: UIColor? = nil
  ) {
    self.weatherConditionSymbol = weatherConditionSymbol
    self.placeName = placeName
    self.temperature = temperature
    self.cloudCoverage = cloudCoverage
    self.humidity = humidity
    self.windspeed = windspeed
    self.backgroundColor = backgroundColor
    self.borderColor = borderColor
  }
  
  init(
    weatherInformationDTO: WeatherInformationDTO,
    temperatureUnitOption: TemperatureUnitOption,
    dimensionalUnitsOption: DimensionalUnitOption,
    isBookmark: Bool
  ) {
    let isDayTime = MeteorologyInformationConversionWorker.isDayTime(for: weatherInformationDTO.dayTimeInformation, coordinates: weatherInformationDTO.coordinates) ?? true
    
    self.init(
      weatherConditionSymbol: MeteorologyInformationConversionWorker.weatherConditionSymbol(
        fromWeatherCode: weatherInformationDTO.weatherCondition.first?.identifier,
        isDayTime: isDayTime
      ),
      placeName: weatherInformationDTO.stationName,
      temperature: MeteorologyInformationConversionWorker.temperatureDescriptor(
        forTemperatureUnit: temperatureUnitOption,
        fromRawTemperature: weatherInformationDTO.atmosphericInformation.temperatureKelvin
      ),
      cloudCoverage: weatherInformationDTO.cloudCoverage.coverage?.append(contentsOf: "%", delimiter: .none),
      humidity: weatherInformationDTO.atmosphericInformation.humidity?.append(contentsOf: "%", delimiter: .none),
      windspeed: MeteorologyInformationConversionWorker.windspeedDescriptor(
        forDistanceSpeedUnit: dimensionalUnitsOption,
        forWindspeed: weatherInformationDTO.windInformation.windspeed
      ),
      backgroundColor: Self.backgroundColor(isDayTime: isDayTime),
      borderColor: Constants.Theme.Color.ViewElement.WeatherInformation.border
    )
  }
}

// MARK: - Helpers

private extension WeatherListInformationTableViewCellModel {
  
  static func backgroundColor(isDayTime: Bool) -> UIColor {
    isDayTime ? Constants.Theme.Color.ViewElement.WeatherInformation.colorBackgroundDay : Constants.Theme.Color.ViewElement.WeatherInformation.colorBackgroundNight
  }
}
