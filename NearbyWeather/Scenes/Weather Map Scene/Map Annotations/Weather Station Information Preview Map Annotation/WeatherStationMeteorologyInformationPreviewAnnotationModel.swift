//
//  WeatherMapAnnotationModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 10.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import MapKit

struct WeatherStationMeteorologyInformationPreviewAnnotationModel { // swiftlint:disable:this type_name
  let title: String?
  let subtitle: String?
  let weatherConditionSymbol: UIImage?
  let isDayTime: Bool?
  let tintColor: UIColor?
  let backgroundColor: UIColor?
  
  init(
    title: String? = nil,
    subtitle: String? = nil,
    weatherConditionSymbol: UIImage? = nil,
    isDayTime: Bool? = false,
    tintColor: UIColor? = nil,
    backgroundColor: UIColor? = nil
  ) {
    self.title = title
    self.subtitle = subtitle
    self.weatherConditionSymbol = weatherConditionSymbol
    self.isDayTime = isDayTime
    self.tintColor = tintColor
    self.backgroundColor = backgroundColor
  }
  
  init(
    weatherInformationDTO: WeatherInformationDTO,
    temperatureUnitOption: TemperatureUnitOption,
    isBookmark: Bool
  ) {
    let isDayTime = MeteorologyInformationConversionWorker.isDayTime(for: weatherInformationDTO.dayTimeInformation, coordinates: weatherInformationDTO.coordinates) ?? true
    
    var weatherConditionSymbol: UIImage?
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
    
    let subtitle = temperatureDescriptor
    
    self.init(
      title: weatherInformationDTO.stationName,
      subtitle: subtitle,
      weatherConditionSymbol: weatherConditionSymbol,
      isDayTime: isDayTime,
      tintColor: Constants.Theme.Color.ViewElement.WeatherInformation.colorBackgroundPrimaryTitle,
      backgroundColor: isDayTime ? Constants.Theme.Color.ViewElement.WeatherInformation.colorBackgroundDay : Constants.Theme.Color.ViewElement.WeatherInformation.colorBackgroundNight
    )
  }
}
