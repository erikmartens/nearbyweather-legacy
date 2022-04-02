//
//  WeatherStationCurrentInformationHeaderCellModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 13.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import UIKit

struct WeatherStationMeteorologyDetailsHeaderCellModel {
  
  let weatherConditionSymbolImage: UIImage?
  let weatherConditionTitle: String?
  let currentTemperature: String?
  let feelsLikeTemperature: String?
  let temperatureHighLow: String?
  let backgroundColor: UIColor
  
  init(
    weatherConditionSymbolImage: UIImage? = nil,
    weatherConditionTitle: String? = nil,
    currentTemperature: String? = nil,
    feelsLikeTemperature: String? = nil,
    temperatureHighLow: String? = nil,
    backgroundColor: UIColor = Constants.Theme.Color.ViewElement.WeatherInformation.colorBackgroundDay
  ) {
    self.weatherConditionSymbolImage = weatherConditionSymbolImage
    self.weatherConditionTitle = weatherConditionTitle
    self.currentTemperature = currentTemperature
    self.feelsLikeTemperature = feelsLikeTemperature
    self.temperatureHighLow = temperatureHighLow
    self.backgroundColor = backgroundColor
  }
  
  init(
    weatherInformationDTO: WeatherInformationDTO,
    temperatureUnitOption: TemperatureUnitOption,
    dimensionalUnitsOption: DimensionalUnitOption,
    isBookmark: Bool
  ) {
    let isDayTime = MeteorologyInformationConversionWorker.isDayTime(for: weatherInformationDTO.dayTimeInformation, coordinates: weatherInformationDTO.coordinates)
    
    self.init(
      weatherConditionSymbolImage: MeteorologyInformationConversionWorker.weatherConditionSymbol(
        fromWeatherCode: weatherInformationDTO.weatherCondition.first?.identifier,
        isDayTime: isDayTime
      ),
      weatherConditionTitle: weatherInformationDTO.weatherCondition.first?.conditionDescription?.capitalized,
      currentTemperature: MeteorologyInformationConversionWorker.temperatureDescriptor(
        forTemperatureUnit: temperatureUnitOption,
        fromRawTemperature: weatherInformationDTO.atmosphericInformation.temperatureKelvin
      ),
      feelsLikeTemperature: String
        .begin()
        .append(contentsOf: R.string.localizable.feels_like().capitalized)
        .append(
          contentsOf: MeteorologyInformationConversionWorker.temperatureDescriptor(
            forTemperatureUnit: temperatureUnitOption,
            fromRawTemperature: weatherInformationDTO.atmosphericInformation.feelsLikesTemperatureKelvin
          ),
          delimiter: .colonSpace
        )
        .ifEmpty(justReturn: ""),
      temperatureHighLow: String
        .begin(with: "↑")
        .append(
          contentsOf: MeteorologyInformationConversionWorker.temperatureDescriptor(
            forTemperatureUnit: temperatureUnitOption,
            fromRawTemperature: weatherInformationDTO.atmosphericInformation.temperatureKelvinHigh
          ),
          delimiter: .none
        )
        .append(contentsOf: "↓", delimiter: .space)
        .append(
          contentsOf: MeteorologyInformationConversionWorker.temperatureDescriptor(
            forTemperatureUnit: temperatureUnitOption,
            fromRawTemperature: weatherInformationDTO.atmosphericInformation.temperatureKelvinLow
          ),
          delimiter: .none
        )
        .ifEmpty(justReturn: ""),
      backgroundColor: (isDayTime ?? true) ? Constants.Theme.Color.ViewElement.WeatherInformation.colorBackgroundDay : Constants.Theme.Color.ViewElement.WeatherInformation.colorBackgroundNight
    )
  }
}
