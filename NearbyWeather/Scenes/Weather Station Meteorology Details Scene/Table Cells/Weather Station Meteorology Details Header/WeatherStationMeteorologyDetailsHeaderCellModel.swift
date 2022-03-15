//
//  WeatherStationCurrentInformationHeaderCellModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 13.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import Foundation

struct WeatherStationMeteorologyDetailsHeaderCellModel {
  
  let weatherConditionSymbol: String?
  let weatherConditionTitle: String?
  let weatherConditionSubtitle: String?
  let temperature: String?
  let daytimeStatus: String?
  
  init(
    weatherConditionSymbol: String? = nil,
    weatherConditionTitle: String? = nil,
    weatherConditionSubtitle: String? = nil,
    temperature: String? = nil,
    daytimeStatus: String? = nil
  ) {
    self.weatherConditionSymbol = weatherConditionSymbol
    self.weatherConditionTitle = weatherConditionTitle
    self.weatherConditionSubtitle = weatherConditionSubtitle
    self.temperature = temperature
    self.daytimeStatus = daytimeStatus
  }
  
  init(
    weatherInformationDTO: WeatherInformationDTO,
    temperatureUnitOption: TemperatureUnitOption,
    dimensionalUnitsOption: DimensionalUnitOption,
    isBookmark: Bool
  ) {
    let isDayTime = MeteorologyInformationConversionWorker.isDayTime(for: weatherInformationDTO.dayTimeInformation, coordinates: weatherInformationDTO.coordinates)
    let isDayTimeString = MeteorologyInformationConversionWorker.isDayTimeString(for: weatherInformationDTO.dayTimeInformation, coordinates: weatherInformationDTO.coordinates)
    let dayCycleStrings = MeteorologyInformationConversionWorker.dayCycleTimeStrings(for: weatherInformationDTO.dayTimeInformation, coordinates: weatherInformationDTO.coordinates)
    
    self.init(
      weatherConditionSymbol: MeteorologyInformationConversionWorker.weatherConditionSymbol(
        fromWeatherCode: weatherInformationDTO.weatherCondition.first?.identifier,
        isDayTime: isDayTime
      ),
      weatherConditionTitle: weatherInformationDTO.weatherCondition.first?.conditionName?.capitalized,
      weatherConditionSubtitle: weatherInformationDTO.weatherCondition.first?.conditionDescription?.capitalized,
      temperature: MeteorologyInformationConversionWorker.temperatureDescriptor(
        forTemperatureUnit: temperatureUnitOption,
        fromRawTemperature: weatherInformationDTO.atmosphericInformation.temperatureKelvin
      ),
      daytimeStatus: String
        .begin(with: isDayTimeString)
        .append(contentsOf: dayCycleStrings?.currentTimeString, delimiter: .space)
        .ifEmpty(justReturn: nil)
    )
  }
}
