//
//  ConversionService.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 09.01.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import Foundation
import MapKit
import APTimeZones

// MARK: - Public Type

extension ConversionWorker {
  struct DayCycleLocalizedTimeStrings {
    let currentTimeString: String
    let sunriseTimeString: String
    let sunsetTimeString: String
  }
}

// MARK: - Local Types

private extension ConversionWorker {
  struct DayCycleDateComponents {
    let currentTimeDateComponentsHour: Int
    let currentTimeDateComponentsMinute: Int
    let sunriseTimeDateComponentsHour: Int
    let sunriseTimeDateComponentsMinute: Int
    let sunsetTimeDateComponentsHour: Int
    let sunsetTimeDateComponentsMinute: Int
    let timeZone: TimeZone
    
    init(
      currentTimeDateComponentsHour: Int,
      currentTimeDateComponentsMinute: Int,
      sunriseTimeDateComponentsHour: Int,
      sunriseTimeDateComponentsMinute: Int,
      sunsetTimeDateComponentsHour: Int,
      sunsetTimeDateComponentsMinute: Int,
      timeZone: TimeZone
    ) {
      self.currentTimeDateComponentsHour = currentTimeDateComponentsHour
      self.currentTimeDateComponentsMinute = currentTimeDateComponentsMinute
      self.sunriseTimeDateComponentsHour = sunriseTimeDateComponentsHour
      self.sunriseTimeDateComponentsMinute = sunriseTimeDateComponentsMinute
      self.sunsetTimeDateComponentsHour = sunsetTimeDateComponentsHour
      self.sunsetTimeDateComponentsMinute = sunsetTimeDateComponentsMinute
      self.timeZone = timeZone
    }
    
    init?(
      currentTimeDateComponentsHour: Int?,
      currentTimeDateComponentsMinute: Int?,
      sunriseTimeDateComponentsHour: Int?,
      sunriseTimeDateComponentsMinute: Int?,
      sunsetTimeDateComponentsHour: Int?,
      sunsetTimeDateComponentsMinute: Int?,
      timeZone: TimeZone?
    ) {
      guard let currentTimeDateComponentHour = currentTimeDateComponentsHour,
            let currentTimeDateComponentMinute = currentTimeDateComponentsMinute,
            let sunriseTimeDateComponentsHour = sunriseTimeDateComponentsHour,
            let sunriseTimeDateComponentsMinute = sunriseTimeDateComponentsMinute,
            let sunsetTimeDateComponentsHour = sunsetTimeDateComponentsHour,
            let sunsetTimeDateComponentsMinute = sunsetTimeDateComponentsMinute,
            let timeZone = timeZone else {
        return nil
      }
      self.init(
        currentTimeDateComponentsHour: currentTimeDateComponentHour,
        currentTimeDateComponentsMinute: currentTimeDateComponentMinute,
        sunriseTimeDateComponentsHour: sunriseTimeDateComponentsHour,
        sunriseTimeDateComponentsMinute: sunriseTimeDateComponentsMinute,
        sunsetTimeDateComponentsHour: sunsetTimeDateComponentsHour,
        sunsetTimeDateComponentsMinute: sunsetTimeDateComponentsMinute,
        timeZone: timeZone
      )
    }
  }
}

// MARK: - Class Definition

final class ConversionWorker {
  
  static func weatherConditionSymbol(fromWeatherCode code: Int?, isDayTime: Bool?) -> String {
    guard let code = code else {
      return "❓"
    }
    switch code {
    case let x where (x >= 200 && x <= 202) || (x >= 230 && x <= 232):
      return "⛈"
    case let x where x >= 210 && x <= 211:
      return "🌩"
    case let x where x >= 212 && x <= 221:
      return "⚡️"
    case let x where x >= 300 && x <= 321:
      return "🌦"
    case let x where x >= 500 && x <= 531:
      return "🌧"
    case let x where x >= 600 && x <= 602:
      return "☃️"
    case let x where x >= 603 && x <= 622:
      return "🌨"
    case let x where x >= 701 && x <= 771:
      return "🌫"
    case let x where x == 781 || x == 900:
      return "🌪"
    case let x where x == 800:
      return (isDayTime ?? false) ? "☀️" : "🌕"
    case let x where x == 801:
      return "🌤"
    case let x where x == 802:
      return "⛅️"
    case let x where x == 803:
      return "🌥"
    case let x where x == 804:
      return "☁️"
    case let x where x >= 952 && x <= 956 || x == 905:
      return "🌬"
    case let x where x >= 957 && x <= 961 || x == 771:
      return "💨"
    case let x where x == 901 || x == 902 || x == 962:
      return "🌀"
    case let x where x == 903:
      return "❄️"
    case let x where x == 904:
      return "🌡"
    case let x where x == 962:
      return "🌋"
    default:
      return "❓"
    }
  }
  
  static func temperatureIntValue(forTemperatureUnit temperatureUnit: TemperatureUnitOption, fromRawTemperature rawTemperature: Double) -> Int? {
    let adjustedTemp: Double
    switch temperatureUnit.value {
    case .celsius:
      adjustedTemp = rawTemperature - 273.15
    case . fahrenheit:
      adjustedTemp = rawTemperature * (9/5) - 459.67
    case .kelvin:
      adjustedTemp = rawTemperature
    }
    
    guard !adjustedTemp.isNaN && adjustedTemp.isFinite else { return nil }
    return Int(adjustedTemp.rounded())
  }
  
  static func temperatureDescriptor(forTemperatureUnit temperatureUnit: TemperatureUnitOption, fromRawTemperature rawTemperature: Double?) -> String? {
    guard let rawTemperature = rawTemperature else {
      return nil
    }
    switch temperatureUnit.value {
    case .celsius:
      return String(format: "%.02f", rawTemperature - 273.15).append(contentsOf: "°C", delimiter: .none)
    case . fahrenheit:
      return String(format: "%.02f", rawTemperature * (9/5) - 459.67).append(contentsOf: "°F", delimiter: .none)
    case .kelvin:
      return String(format: "%.02f", rawTemperature).append(contentsOf: "°K", delimiter: .none)
    }
  }
  
  static func windspeedDescriptor(forDistanceSpeedUnit distanceSpeedUnit: DimensionalUnitsOption, forWindspeed windspeed: Double?) -> String? {
    guard let windspeed = windspeed else {
      return nil
    }
    switch distanceSpeedUnit.value {
    case .metric:
      return String(format: "%.02f", windspeed).append(contentsOf: R.string.localizable.kph(), delimiter: .space)
    case .imperial:
      return String(format: "%.02f", windspeed / 1.609344).append(contentsOf: R.string.localizable.mph(), delimiter: .space)
    }
  }
  
  static func distanceDescriptor(forDistanceSpeedUnit distanceSpeedUnit: DimensionalUnitsOption, forDistanceInMetres distance: Double) -> String {
    switch distanceSpeedUnit.value {
    case .metric:
      return String(format: "%.02f", distance/1000).append(contentsOf: R.string.localizable.km(), delimiter: .space)
    case .imperial:
      return String(format: "%.02f", distance/1609.344).append(contentsOf: R.string.localizable.mi(), delimiter: .space)
    }
  }
  
  static func windDirectionDescriptor(forWindDirection degrees: Double) -> String {
    return String(format: "%.02f", degrees).append(contentsOf: "°", delimiter: .none)
  }
  
  static func isDayTime(for dayTimeInformation: WeatherInformationDTO.DaytimeInformation?, coordinates: WeatherInformationDTO.Coordinates) -> Bool? {
    
    guard let cycle = dayCycleDateComponents(for: dayTimeInformation, coordinates: coordinates) else {
      return nil
    }
    
    return ((cycle.currentTimeDateComponentsHour == cycle.sunriseTimeDateComponentsHour
              && cycle.currentTimeDateComponentsMinute >= cycle.sunriseTimeDateComponentsMinute)
              || cycle.currentTimeDateComponentsHour > cycle.sunriseTimeDateComponentsHour)
      && ((cycle.currentTimeDateComponentsHour == cycle.sunsetTimeDateComponentsHour
            && cycle.currentTimeDateComponentsMinute <= cycle.sunsetTimeDateComponentsMinute)
            || cycle.currentTimeDateComponentsHour < cycle.sunsetTimeDateComponentsHour)
  }
  
  static func isDayTimeString(for dayTimeInformation: WeatherInformationDTO.DaytimeInformation?, coordinates: WeatherInformationDTO.Coordinates) -> String? {
    guard let isDayTime = isDayTime(for: dayTimeInformation, coordinates: coordinates) else {
      return nil
    }
    return isDayTime ? R.string.localizable.dayTime() : R.string.localizable.nightTime()
  }
  
  static func dayCycleTimeStrings(for dayTimeInformation: WeatherInformationDTO.DaytimeInformation?, coordinates: WeatherInformationDTO.Coordinates) -> DayCycleLocalizedTimeStrings? {
    
    guard let cycle = dayCycleDateComponents(for: dayTimeInformation, coordinates: coordinates),
          let sunriseDate = Calendar.current.date(from: DateComponents(hour: cycle.sunriseTimeDateComponentsHour, minute: cycle.sunriseTimeDateComponentsMinute)),
          let sunsetDate = Calendar.current.date(from: DateComponents(hour: cycle.sunsetTimeDateComponentsHour, minute: cycle.sunsetTimeDateComponentsMinute)) else {
      return nil
    }
    
    let dateFormatter = DateFormatter()
    dateFormatter.calendar = .current
    dateFormatter.timeZone = cycle.timeZone
    dateFormatter.dateStyle = .none
    dateFormatter.timeStyle = .short
    
    return DayCycleLocalizedTimeStrings(
      currentTimeString: dateFormatter.string(from: Date()),
      sunriseTimeString: dateFormatter.string(from: sunriseDate),
      sunsetTimeString: dateFormatter.string(from: sunsetDate)
    )
  }
  
  static func countryName(for countryCode: String) -> String? {
    Locale.current.localizedString(forRegionCode: countryCode)
  }
  
  static func usStateName(for stateCode: String) -> String? {
    UnitedStatesOfAmericaStatesList.statesDictionary[stateCode]
  }
}

// MARK: - Helpers

private extension ConversionWorker {
  
  static func dayCycleDateComponents(for dayTimeInformation: WeatherInformationDTO.DaytimeInformation?, coordinates: WeatherInformationDTO.Coordinates) -> DayCycleDateComponents? {
    
    guard let sunrise =  dayTimeInformation?.sunrise,
          let sunset =  dayTimeInformation?.sunset,
          let latitude = coordinates.latitude,
          let longitude = coordinates.longitude else {
      return nil
    }
    
    let location = CLLocation(latitude: latitude, longitude: longitude)
    let timeZone = location.timeZone()
    
    var calendar = Calendar.current
    calendar.timeZone = location.timeZone()
    
    let currentTimeDateComponents = calendar.dateComponents([.hour, .minute], from: Date())
    let sunriseDate = Date(timeIntervalSince1970: sunrise)
    let sunriseDateComponents = calendar.dateComponents([.hour, .minute], from: sunriseDate)
    let sunsetDate = Date(timeIntervalSince1970: sunset)
    let sunsetDateComponents = calendar.dateComponents([.hour, .minute], from: sunsetDate)
    
    return DayCycleDateComponents(
      currentTimeDateComponentsHour: currentTimeDateComponents.hour,
      currentTimeDateComponentsMinute: currentTimeDateComponents.minute,
      sunriseTimeDateComponentsHour: sunriseDateComponents.hour,
      sunriseTimeDateComponentsMinute: sunriseDateComponents.minute,
      sunsetTimeDateComponentsHour: sunsetDateComponents.hour,
      sunsetTimeDateComponentsMinute: sunsetDateComponents.minute,
      timeZone: timeZone
    )
  }
}
