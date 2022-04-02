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
  let backgroundColor: UIColor
  
  init(
    weatherConditionSymbolImage: UIImage? = nil,
    weatherConditionTitle: String? = nil,
    currentTemperature: String? = nil,
    backgroundColor: UIColor = Constants.Theme.Color.ViewElement.WeatherInformation.colorBackgroundDay
  ) {
    self.weatherConditionSymbolImage = weatherConditionSymbolImage
    self.weatherConditionTitle = weatherConditionTitle
    self.currentTemperature = currentTemperature
    self.backgroundColor = backgroundColor
  }
  
  init(
    weatherInformationDTO: WeatherInformationDTO,
    temperatureUnitOption: TemperatureUnitOption,
    dimensionalUnitsOption: DimensionalUnitOption,
    isBookmark: Bool
  ) {
    let isDayTime = MeteorologyInformationConversionWorker.isDayTime(for: weatherInformationDTO)
    
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
      backgroundColor: (isDayTime ?? true) ? Constants.Theme.Color.ViewElement.WeatherInformation.colorBackgroundDay : Constants.Theme.Color.ViewElement.WeatherInformation.colorBackgroundNight
    )
  }
}
