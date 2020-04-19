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
  let isBookmark: Bool
  
  init(
    title: String?,
    subtitle: String?,
    isDayTime: Bool?,
    coordinate: CLLocationCoordinate2D,
    locationId: Int,
    isBookmark: Bool
  ) {
    self.title = title
    self.subtitle = subtitle
    self.isDayTime = isDayTime
    self.coordinate = coordinate
    self.locationId = locationId
    self.isBookmark = isBookmark
  }
  
  convenience init?(weatherDTO: WeatherInformationDTO?, isBookmark: Bool) {
    guard let weatherDTO = weatherDTO,
      let latitude = weatherDTO.coordinates.latitude,
      let longitude = weatherDTO.coordinates.longitude else {
        return nil
    }
    
    let isDayTime = ConversionWorker.isDayTime(for: weatherDTO.daytimeInformation, coordinates: weatherDTO.coordinates) ?? true
    
    var weatherConditionSymbol: String?
    if let weatherConditionIdentifier = weatherDTO.weatherCondition.first?.identifier {
      weatherConditionSymbol = ConversionWorker.weatherConditionSymbol(
        fromWeatherCode: weatherConditionIdentifier,
        isDayTime: isDayTime
      )
    }
    
    var temperatureDescriptor: String?
    if let temperatureKelvin = weatherDTO.atmosphericInformation.temperatureKelvin {
      temperatureDescriptor = ConversionWorker.temperatureDescriptor(
        forTemperatureUnit: PreferencesDataService.shared.temperatureUnit,
        fromRawTemperature: temperatureKelvin
      )
    }
    
    let subtitle: String? = ""
      .append(contentsOf: weatherConditionSymbol, delimiter: .space)
      .append(contentsOf: temperatureDescriptor, delimiter: .space)
      .ifEmpty(justReturn: nil)
    
    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    
    self.init(
      title: weatherDTO.cityName,
      subtitle: subtitle,
      isDayTime: isDayTime,
      coordinate: coordinate,
      locationId: weatherDTO.cityID,
      isBookmark: isBookmark
    )
  }
}
