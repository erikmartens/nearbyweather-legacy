//
//  ListWeatherInformationTableCellModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit

struct WeatherListInformationTableViewCellModel {
  let weatherConditionSymbolImage: UIImage?
  let placeName: String?
  let temperature: String?
  let cloudCoverage: String?
  let humidity: String?
  let windspeed: String?
  let backgroundColor: UIColor?
  
  init(
    weatherConditionSymbolImage: UIImage? = nil,
    placeName: String? =  nil,
    temperature: String? = nil,
    cloudCoverage: String? = nil,
    humidity: String? = nil,
    windspeed: String? = nil,
    backgroundColor: UIColor? = nil
  ) {
    self.weatherConditionSymbolImage = weatherConditionSymbolImage
    self.placeName = placeName
    self.temperature = temperature
    self.cloudCoverage = cloudCoverage
    self.humidity = humidity
    self.windspeed = windspeed
    self.backgroundColor = backgroundColor
  }
  
  init(
    weatherInformationDTO: WeatherInformationDTO,
    temperatureUnitOption: TemperatureUnitOption,
    dimensionalUnitsOption: DimensionalUnitOption,
    isBookmark: Bool
  ) {
    let isDayTime = MeteorologyInformationConversionWorker.isDayTime(for: weatherInformationDTO.dayTimeInformation, coordinates: weatherInformationDTO.coordinates) ?? true
    
    self.init(
      weatherConditionSymbolImage: MeteorologyInformationConversionWorker.weatherConditionSymbol(
        fromWeatherCode: weatherInformationDTO.weatherCondition.first?.identifier,
        isDayTime: isDayTime
      ),
      placeName: weatherInformationDTO.stationName,
      temperature: MeteorologyInformationConversionWorker.temperatureDescriptor(
        forTemperatureUnit: temperatureUnitOption,
        fromRawTemperature: weatherInformationDTO.atmosphericInformation.temperatureKelvin
      ),
      cloudCoverage: MeteorologyInformationConversionWorker.cloudCoverageDescriptor(for: weatherInformationDTO.cloudCoverage.coverage),
      humidity: MeteorologyInformationConversionWorker.humidityDescriptor(for: weatherInformationDTO.atmosphericInformation.humidity),
      windspeed: MeteorologyInformationConversionWorker.windspeedDescriptor(
        forDistanceSpeedUnit: dimensionalUnitsOption,
        forWindspeed: weatherInformationDTO.windInformation.windspeed
      ),
      backgroundColor: isDayTime ? Constants.Theme.Color.ViewElement.WeatherInformation.colorBackgroundDay : Constants.Theme.Color.ViewElement.WeatherInformation.colorBackgroundNight
    )
  }
}
