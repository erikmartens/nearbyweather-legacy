//
//  WeatherLocationMapAnnotation.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.02.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import Foundation
import MapKit

final class WeatherLocationMapAnnotation: NSObject, MKAnnotation {
  let title: String?
  let subtitle: String?
  let isDayTime: Bool?
  let coordinate: CLLocationCoordinate2D
  let locationId: Int
  
  init(
    title: String?,
    subtitle: String?,
    isDayTime: Bool?,
    coordinate: CLLocationCoordinate2D,
    locationId: Int
  ) {
    self.title = title
    self.subtitle = subtitle
    self.isDayTime = isDayTime
    self.coordinate = coordinate
    self.locationId = locationId
  }
  
  convenience init?(weatherDTO: WeatherInformationDTO?) {
    guard let weatherDTO = weatherDTO else { return nil }
    
    var weatherConditionSymbol: String?
    if let weatherConditionIdentifier = weatherDTO.weatherCondition.first?.identifier {
      weatherConditionSymbol = ConversionWorker.weatherConditionSymbol(fromWeatherCode: weatherConditionIdentifier)
    }
    
    var temperatureDescriptor: String?
    if let temperatureKelvin = weatherDTO.atmosphericInformation.temperatureKelvin {
      temperatureDescriptor = ConversionWorker.temperatureDescriptor(
        forTemperatureUnit: PreferencesDataService.shared.temperatureUnit,
        fromRawTemperature: temperatureKelvin
      )
    }
    
    let subtitle: String? = ""
      .append(contentsOf: weatherConditionSymbol, delimiter: " ")
      .append(contentsOf: temperatureDescriptor, delimiter: " ")
      .ifEmpty(justReturn: nil)
    
    let isDayTime = ConversionWorker.isDayTime(forWeatherDTO: weatherDTO)
    
    let coordinate = CLLocationCoordinate2D(latitude: weatherDTO.coordinates.latitude, longitude: weatherDTO.coordinates.longitude)
    
    self.init(title: weatherDTO.cityName, subtitle: subtitle, isDayTime: isDayTime, coordinate: coordinate, locationId: weatherDTO.cityID)
  }
}
