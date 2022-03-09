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
    let isDayTime = ConversionWorker.isDayTime(for: weatherInformationDTO.dayTimeInformation, coordinates: weatherInformationDTO.coordinates) ?? true
    
    self.init(
      weatherConditionSymbol: ConversionWorker.weatherConditionSymbol(
        fromWeatherCode: weatherInformationDTO.weatherCondition.first?.identifier,
        isDayTime: isDayTime
      ),
      placeName: weatherInformationDTO.stationName,
      temperature: ConversionWorker.temperatureDescriptor(
        forTemperatureUnit: temperatureUnitOption,
        fromRawTemperature: weatherInformationDTO.atmosphericInformation.temperatureKelvin
      ),
      cloudCoverage: weatherInformationDTO.cloudCoverage.coverage?.append(contentsOf: "%", delimiter: .none),
      humidity: weatherInformationDTO.atmosphericInformation.humidity?.append(contentsOf: "%", delimiter: .none),
      windspeed: ConversionWorker.windspeedDescriptor(
        forDistanceSpeedUnit: dimensionalUnitsOption,
        forWindspeed: weatherInformationDTO.windInformation.windspeed
      ),
      backgroundColor: Self.backgroundColor(for: isBookmark, isDayTime: isDayTime),
      borderColor: Self.borderColor(for: isBookmark)
    )
  }
}

// MARK: - Helpers

private extension WeatherListInformationTableViewCellModel {
  
  static func borderColor(for isBookmark: Bool) -> UIColor {
    isBookmark
      ? Constants.Theme.Color.ViewElement.borderBookmark
      : Constants.Theme.Color.ViewElement.borderNearby
  }
  
  static func backgroundColor(for isBookmark: Bool, isDayTime: Bool) -> UIColor {
    isBookmark
      ? (isDayTime ? Constants.Theme.Color.MarqueColors.bookmarkDay : Constants.Theme.Color.MarqueColors.bookmarkNight)
      : (isDayTime ? Constants.Theme.Color.MarqueColors.nearbyDay : Constants.Theme.Color.MarqueColors.nearbyNight)
  }
}
