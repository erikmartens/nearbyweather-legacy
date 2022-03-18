//
//  WeatherMapAnnotationModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 10.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import MapKit

struct WeatherMapAnnotationModel {
  let title: String?
  let subtitle: String?
  let isDayTime: Bool?
  let tintColor: UIColor?
  let backgroundColor: UIColor?
  
  init(
    title: String? = nil,
    subtitle: String? = nil,
    isDayTime: Bool? = false,
    borderColor: UIColor? = nil,
    backgroundColor: UIColor? = nil
  ) {
    self.title = title
    self.subtitle = subtitle
    self.isDayTime = isDayTime
    self.tintColor = borderColor
    self.backgroundColor = backgroundColor
  }
  
  init(
    weatherInformationDTO: WeatherInformationDTO,
    temperatureUnitOption: TemperatureUnitOption,
    isBookmark: Bool
  ) {
    let isDayTime = MeteorologyInformationConversionWorker.isDayTime(for: weatherInformationDTO.dayTimeInformation, coordinates: weatherInformationDTO.coordinates) ?? true
    
    var weatherConditionSymbol: String?
    if let weatherConditionIdentifier = weatherInformationDTO.weatherCondition.first?.identifier {
      weatherConditionSymbol = MeteorologyInformationConversionWorker.weatherConditionSymbol(
        fromWeatherCode: weatherConditionIdentifier,
        isDayTime: isDayTime
      )
    }
    
    var temperatureDescriptor: String?
    if let temperatureKelvin = weatherInformationDTO.atmosphericInformation.temperatureKelvin {
      temperatureDescriptor = MeteorologyInformationConversionWorker.temperatureDescriptor(
        forTemperatureUnit: temperatureUnitOption,
        fromRawTemperature: temperatureKelvin
      )
    }
    
    let subtitle: String? = ""
      .append(contentsOf: weatherConditionSymbol, delimiter: .space)
      .append(contentsOf: temperatureDescriptor, delimiter: .space)
      .ifEmpty(justReturn: nil)
    
    self.init(
      title: weatherInformationDTO.stationName,
      subtitle: subtitle,
      isDayTime: isDayTime,
      borderColor: Constants.Theme.Color.ViewElement.WeatherInformation.border,
      backgroundColor: isDayTime ? Constants.Theme.Color.ViewElement.WeatherInformation.colorBackgroundDay : Constants.Theme.Color.ViewElement.WeatherInformation.colorBackgroundNight
    )
  }
}
