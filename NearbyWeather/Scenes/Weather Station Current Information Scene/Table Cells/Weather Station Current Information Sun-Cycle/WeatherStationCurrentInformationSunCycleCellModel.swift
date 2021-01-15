//
//  WeatherStationCurrentInformationSunCycleCellModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 14.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import Foundation

struct WeatherStationCurrentInformationSunCycleCellModel {
  
  let sunriseTimeString: String?
  let sunsetTimeString: String?
  
  init(
    sunriseTimeString: String? = nil,
    sunsetTimeString: String? = nil
  ) {
    self.sunriseTimeString = sunriseTimeString
    self.sunsetTimeString = sunsetTimeString
  }
  
  init(
    dayTimeInformationDTO: WeatherInformationDTO.DayTimeInformationDTO,
    coordinatesDTO: WeatherInformationDTO.CoordinatesDTO
  ) {
    let dayCycleStrings = ConversionWorker.dayCycleTimeStrings(for: dayTimeInformationDTO, coordinates: coordinatesDTO)
    
    self.init(
      sunriseTimeString: dayCycleStrings?.sunriseTimeString,
      sunsetTimeString: dayCycleStrings?.sunsetTimeString
    )
  }
}
