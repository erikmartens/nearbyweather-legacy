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
  let borderColor: UIColor?
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
    self.borderColor = borderColor
    self.backgroundColor = backgroundColor
  }
  
  init(weatherInformationDTO: WeatherInformationDTO, temperatureUnitOption: TemperatureUnitOption, isBookmark: Bool) {
    let isDayTime = ConversionWorker.isDayTime(for: weatherInformationDTO.daytimeInformation, coordinates: weatherInformationDTO.coordinates) ?? true
    
    var weatherConditionSymbol: String?
    if let weatherConditionIdentifier = weatherInformationDTO.weatherCondition.first?.identifier {
      weatherConditionSymbol = ConversionWorker.weatherConditionSymbol(
        fromWeatherCode: weatherConditionIdentifier,
        isDayTime: isDayTime
      )
    }
    
    var temperatureDescriptor: String?
    if let temperatureKelvin = weatherInformationDTO.atmosphericInformation.temperatureKelvin {
      temperatureDescriptor = ConversionWorker.temperatureDescriptor(
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
      borderColor: Self.borderColor(for: isBookmark),
      backgroundColor: Self.backgroundColor(for: isBookmark, isDayTime: isDayTime)
    )
  }
}

// MARK: - Helpers

private extension WeatherMapAnnotationModel {
  
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
