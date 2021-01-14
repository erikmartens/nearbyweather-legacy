//
//  WeatherStationCurrentInformationHeaderCellModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 13.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import Foundation

struct WeatherStationCurrentInformationHeaderCellModel {
  
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
    dimensionalUnitsOption: DimensionalUnitsOption,
    isBookmark: Bool
  ) {
    let isDayTime = ConversionWorker.isDayTime(for: weatherInformationDTO.daytimeInformation, coordinates: weatherInformationDTO.coordinates)
    let isDayTimeString = ConversionWorker.isDayTimeString(for: weatherInformationDTO.daytimeInformation, coordinates: weatherInformationDTO.coordinates)
    let dayCycleStrings = ConversionWorker.dayCycleTimeStrings(for: weatherInformationDTO.daytimeInformation, coordinates: weatherInformationDTO.coordinates)
    
    self.init(
      weatherConditionSymbol: ConversionWorker.weatherConditionSymbol(
        fromWeatherCode: weatherInformationDTO.weatherCondition.first?.identifier,
        isDayTime: isDayTime
      ),
      weatherConditionTitle: weatherInformationDTO.weatherCondition.first?.conditionName,
      weatherConditionSubtitle: weatherInformationDTO.weatherCondition.first?.conditionDescription,
      temperature: ConversionWorker.temperatureDescriptor(
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
