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

extension MeteorologyInformationConversionWorker {
  struct DayCycleLocalizedTimeStrings {
    let currentTimeString: String
    let sunriseTimeString: String
    let sunsetTimeString: String
  }
}

// MARK: - Local Types

private extension MeteorologyInformationConversionWorker {
  
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
  
  enum WindDirection {
    case cardinalDirectionN
    case cardinalDirectionNNE
    case cardinalDirectionNE
    case cardinalDirectionENE
    case cardinalDirectionE
    case cardinalDirectionESE
    case cardinalDirectionSE
    case cardinalDirectionSSE
    case cardinalDirectionS
    case cardinalDirectionSSW
    case cardinalDirectionSW
    case cardinalDirectionWSW
    case cardinalDirectionW
    case cardinalDirectionWNW
    case cardinalDirectionNW
    case cardinalDirectionNNW
    
    init?(degrees: Double) { // swiftlint:disable:this cyclomatic_complexity
      guard degrees >= 0 && degrees <= 360 else {
        return nil
      }
      switch degrees {
      case let x where (x >= 348.75 && x <= 360) || (x >= 0 && x < 11.25):
        self = .cardinalDirectionN
      case let x where x >= 11.25 && x < 33.75:
        self = .cardinalDirectionNNE
      case let x where x >= 33.75 && x < 56.25:
        self = .cardinalDirectionNE
      case let x where x >= 56.25 && x < 78.75:
        self = .cardinalDirectionENE
      case let x where x >= 78.75 && x < 101.25:
        self = .cardinalDirectionE
      case let x where x >= 101.25 && x < 123.75:
        self = .cardinalDirectionESE
      case let x where x >= 123.75 && x < 146.25:
        self = .cardinalDirectionSE
      case let x where x >= 146.25 && x < 168.75:
        self = .cardinalDirectionSSE
      case let x where x >= 168.75 && x < 191.25:
        self = .cardinalDirectionS
      case let x where x >= 191.25 && x < 213.75:
        self = .cardinalDirectionSSW
      case let x where x >= 213.75 && x < 236.25:
        self = .cardinalDirectionSW
      case let x where x >= 236.25 && x < 258.75:
        self = .cardinalDirectionWSW
      case let x where x >= 258.75 && x < 281.25:
        self = .cardinalDirectionW
      case let x where x >= 281.25 && x < 303.75:
        self = .cardinalDirectionWNW
      case let x where x >= 303.75 && x < 326.25:
        self = .cardinalDirectionNW
      case let x where x >= 326.25 && x < 348.75:
        self = .cardinalDirectionNNW
      default:
        return nil
      }
    }
    
    var stringValue: String {
      switch self {
      case .cardinalDirectionN: return "N"
      case .cardinalDirectionNNE: return "NNE"
      case .cardinalDirectionNE: return "NE"
      case .cardinalDirectionENE: return "ENE"
      case .cardinalDirectionE: return "E"
      case .cardinalDirectionESE: return "ESE"
      case .cardinalDirectionSE: return "SE"
      case .cardinalDirectionSSE: return "SSE"
      case .cardinalDirectionS: return "S"
      case .cardinalDirectionSSW: return "SSW"
      case .cardinalDirectionSW: return "SW"
      case .cardinalDirectionWSW: return "WSW"
      case .cardinalDirectionW: return "W"
      case .cardinalDirectionWNW: return "WNW"
      case .cardinalDirectionNW: return "NW"
      case .cardinalDirectionNNW: return "NNW"
      }
    }
  }
}

// MARK: - Class Definition

final class MeteorologyInformationConversionWorker {
  
  private static var numberFormatter: NumberFormatter {
    let formatter = NumberFormatter()
    formatter.locale = Locale.current
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 1
    return formatter
  }
}

// MARK: - Public Functions

extension MeteorologyInformationConversionWorker {
  
  static func weatherConditionSymbol(fromWeatherCode code: Int?, isDayTime: Bool?) -> UIImage { // swiftlint:disable:this cyclomatic_complexity
    typealias WeatherInformationColor = Constants.Theme.Color.ViewElement.WeatherInformation
    let isDayTime = isDayTime ?? true
    
    let defaultImage = Factory.Image.make(fromType: .weatherConditionSymbol(
      systemImageName: "questionmark",
      colorPalette: [Constants.Theme.Color.SystemColor.red]
    ))
    
    guard let code = code else {
      return defaultImage
    }
    switch code {
    case let x where (x >= 200 && x <= 202) || (x >= 230 && x <= 232):
      return Factory.Image.make(fromType: .weatherConditionSymbol(
        systemImageName: "cloud.bolt.rain.fill",
        colorPalette: [
          WeatherInformationColor.white,
          WeatherInformationColor.cyan,
          WeatherInformationColor.yellow
        ]
      ))
    case let x where x >= 210 && x <= 211:
      return Factory.Image.make(fromType: .weatherConditionSymbol(
        systemImageName: "cloud.bolt.fill",
        colorPalette: [
          WeatherInformationColor.white,
          WeatherInformationColor.yellow
        ]
      ))
    case let x where x >= 212 && x <= 221:
      return Factory.Image.make(fromType: .weatherConditionSymbol(
        systemImageName: "bolt.fill",
        colorPalette: [
          WeatherInformationColor.yellow
        ]
      ))
    case let x where x == 300 || x == 301 || x == 310:
      return Factory.Image.make(fromType: .weatherConditionSymbol(
        systemImageName: isDayTime ? "cloud.sun.rain.fill" : "cloud.moon.rain.fill",
        colorPalette: [
          WeatherInformationColor.white,
          isDayTime ? WeatherInformationColor.yellow : .purple,
          WeatherInformationColor.cyan
        ]
      ))
    case let x where x == 302 || (x >= 311 && x <= 321):
      return Factory.Image.make(fromType: .weatherConditionSymbol(
        systemImageName: "cloud.drizzle.fill",
        colorPalette: [
          WeatherInformationColor.white,
          WeatherInformationColor.cyan
        ]
      ))
    case let x where x == 500 || x == 501:
      return Factory.Image.make(fromType: .weatherConditionSymbol(
        systemImageName: "cloud.rain.fill",
        colorPalette: [
          WeatherInformationColor.white,
          WeatherInformationColor.cyan
        ]
      ))
    case let x where x == 511:
      return Factory.Image.make(fromType: .weatherConditionSymbol(
        systemImageName: "cloud.sleet.fill",
        colorPalette: [
          WeatherInformationColor.white,
          WeatherInformationColor.cyan
        ]
      ))
    case let x where (x >= 502 && x <= 504) || (x >= 520 && x <= 531) :
      return Factory.Image.make(fromType: .weatherConditionSymbol(
        systemImageName: "cloud.heavyrain.fill",
        colorPalette: [
          WeatherInformationColor.white,
          WeatherInformationColor.cyan
        ]
      ))
    case let x where (x >= 600 && x <= 602) || x >= 620 && x <= 622:
      return Factory.Image.make(fromType: .weatherConditionSymbol(
        systemImageName: "cloud.snow.fill",
        colorPalette: [
          WeatherInformationColor.white,
          WeatherInformationColor.cyan
        ]
      ))
    case let x where x >= 611 && x <= 616:
      return Factory.Image.make(fromType: .weatherConditionSymbol(
        systemImageName: "cloud.sleet.fill",
        colorPalette: [
          WeatherInformationColor.white,
          WeatherInformationColor.cyan
        ]
      ))
    case let x where x == 701:
      return Factory.Image.make(fromType: .weatherConditionSymbol(
        systemImageName: "cloud.fog",
        colorPalette: [
          WeatherInformationColor.white.withAlphaComponent(0.5)
        ]
      ))
    case let x where x == 711 || x == 762:
      return Factory.Image.make(fromType: .weatherConditionSymbol(
        systemImageName: "smoke.fill",
        colorPalette: [
          WeatherInformationColor.gray.withAlphaComponent(0.5)
        ]
      ))
    case let x where x == 721:
      return Factory.Image.make(fromType: .weatherConditionSymbol(
        systemImageName: "sun.haze.fill",
        colorPalette: [
          WeatherInformationColor.yellow,
          WeatherInformationColor.white.withAlphaComponent(0.5)
        ]
      ))
    case let x where x == 731 || x == 751 || x == 761:
      return Factory.Image.make(fromType: .weatherConditionSymbol(
        systemImageName: "sun.dust.fill",
        colorPalette: [
          WeatherInformationColor.yellow,
          WeatherInformationColor.yellow.withAlphaComponent(0.5)
        ]
      ))
    case let x where x == 741:
      return Factory.Image.make(fromType: .weatherConditionSymbol(
        systemImageName: "cloud.fog.fill",
        colorPalette: [
          WeatherInformationColor.white,
          WeatherInformationColor.white.withAlphaComponent(0.5)
        ]
      ))
    case let x where x == 771:
      return Factory.Image.make(fromType: .weatherConditionSymbol(
        systemImageName: "wind",
        colorPalette: [
          WeatherInformationColor.white
        ]
      ))
    case let x where x == 781 || x == 900:
      return Factory.Image.make(fromType: .weatherConditionSymbol(
        systemImageName: "tornado",
        colorPalette: [
          WeatherInformationColor.gray
        ]
      ))
    case let x where x == 800:
      return Factory.Image.make(fromType: .weatherConditionSymbol(
        systemImageName: isDayTime ? "sun.max.fill" : "moon.stars.fill",
        colorPalette: [
          isDayTime ? WeatherInformationColor.yellow : .purple
        ]
      ))
    case let x where x >= 801 && x <= 803:
      return Factory.Image.make(fromType: .weatherConditionSymbol(
        systemImageName: isDayTime ? "cloud.sun.fill" : "cloud.moon.fill",
        colorPalette: [
          WeatherInformationColor.white,
          isDayTime ? WeatherInformationColor.yellow : .purple
        ]
      ))
    case let x where x >= 803 && x <= 804:
      return Factory.Image.make(fromType: .weatherConditionSymbol(
        systemImageName: "cloud.fill",
        colorPalette: [
          WeatherInformationColor.white
        ]
      ))
    case let x where (x >= 952 && x <= 961) || x == 905:
      return Factory.Image.make(fromType: .weatherConditionSymbol(
        systemImageName: "wind",
        colorPalette: [
          WeatherInformationColor.white
        ]
      ))
    case let x where x == 901 || x == 902:
      return Factory.Image.make(fromType: .weatherConditionSymbol(
        systemImageName: "hurricane",
        colorPalette: [
          WeatherInformationColor.white
        ]
      ))
    case let x where x == 903:
      return Factory.Image.make(fromType: .weatherConditionSymbol(
        systemImageName: "wind.snow",
        colorPalette: [
          WeatherInformationColor.white,
          WeatherInformationColor.cyan
        ]
      ))
    case let x where x == 904:
      return Factory.Image.make(fromType: .weatherConditionSymbol(
        systemImageName: "thermometer.sun.fill",
        colorPalette: [
          WeatherInformationColor.red,
          WeatherInformationColor.yellow
        ]
      ))
    case let x where x == 962:
      return Factory.Image.make(fromType: .weatherConditionSymbol(
        systemImageName: "flame.fill",
        colorPalette: [
          WeatherInformationColor.red,
          WeatherInformationColor.yellow
        ]
      ))
    default:
      return defaultImage
    }
  }
  
  static func temperatureIntValue(forTemperatureUnit temperatureUnit: TemperatureUnitOption, fromRawTemperature rawTemperature: Double) -> Int? {
    let adjustedTemp: Double
    switch temperatureUnit.value {
    case .celsius:
      adjustedTemp = rawTemperature - 273.15
    case .fahrenheit:
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
      return numberFormatter.string(from: rawTemperature - 273.15)?.append(contentsOf: "°C", delimiter: .none)
    case .fahrenheit:
      return numberFormatter.string(from: rawTemperature * (9/5) - 459.67)?.append(contentsOf: "°F", delimiter: .none)
    case .kelvin:
      return numberFormatter.string(from: rawTemperature)?.append(contentsOf: "°K", delimiter: .none)
    }
  }
  
  static func cloudCoverageDescriptor(for cloudCoverage: Double?) -> String? {
    guard let cloudCoverage = cloudCoverage else {
      return nil
    }
    return numberFormatter.string(from: cloudCoverage)?.append(contentsOf: "%", delimiter: .none)
  }
  
  static func humidityDescriptor(for humidity: Double?) -> String? {
    guard let humidity = humidity else {
      return nil
    }
    return numberFormatter.string(from: humidity)?.append(contentsOf: "%", delimiter: .none)
  }
  
  static func airPressureDescriptor(for airPressure: Double?) -> String? {
    guard let airPressure = airPressure else {
      return nil
    }
    return numberFormatter.string(from: airPressure)?.append(contentsOf: "hpa", delimiter: .space)
  }
  
  static func distanceDescriptor(forDistanceSpeedUnit distanceSpeedUnit: DimensionalUnitOption, forDistanceInMetres distance: Double) -> String? {
    let numberFormaatter = numberFormatter
    numberFormaatter.maximumFractionDigits = distance > 100000 ? 0 : 1
    
    switch distanceSpeedUnit.value {
    case .metric:
      return numberFormaatter.string(from: distance/1000)?.append(contentsOf: R.string.localizable.km(), delimiter: .space)
    case .imperial:
      return numberFormaatter.string(from: distance/1609.344)?.append(contentsOf: R.string.localizable.mi(), delimiter: .space)
    }
  }
  
  static func windspeedDescriptor(forDistanceSpeedUnit distanceSpeedUnit: DimensionalUnitOption, forWindspeed windspeed: Double?) -> String? {
    guard let windspeed = windspeed else {
      return nil
    }
    switch distanceSpeedUnit.value {
    case .metric:
      return numberFormatter.string(from: windspeed)?.append(contentsOf: R.string.localizable.kph(), delimiter: .space)
    case .imperial:
      return numberFormatter.string(from: windspeed / 1.609344)?.append(contentsOf: R.string.localizable.mph(), delimiter: .space)
    }
  }
  
  static func windDirectionDescriptor(forWindDirection degrees: Double) -> String? {
    let degreesString = numberFormatter.string(from: degrees)?.append(contentsOf: "°", delimiter: .none)
    return degrees.toCardinalDirectionString?.append(contentsOf: degreesString, encasing: .roundBrackets, delimiter: .space)
  }
  
  static func coordinatesDescriptorFor(latitude lat: Double?, longitude lon: Double?) -> String? {
    guard let latitude = lat, let longitude = lon else {
      return nil
    }
    let numberFormatter = numberFormatter
    numberFormatter.decimalSeparator = "."
    return String
      .begin(with: numberFormatter.string(from: latitude))
      .append(contentsOf: numberFormatter.string(from: longitude), delimiter: .comma)
  }
  
  static func coordinatesCopyTextFor(latitude lat: Double?, longitude lon: Double?) -> String? {
    guard let latitude = lat, let longitude = lon else {
      return nil
    }
    let numberFormatter = numberFormatter
    numberFormatter.decimalSeparator = "."
    numberFormatter.minimumFractionDigits = 6
    numberFormatter.maximumFractionDigits = 12
    
    return String
      .begin(with: numberFormatter.string(from: latitude))
      .append(contentsOf: numberFormatter.string(from: longitude), delimiter: .comma)
  }
  
  static func isDayTime(for dayTimeInformation: WeatherInformationDTO.DayTimeInformationDTO?, coordinates: WeatherInformationDTO.CoordinatesDTO) -> Bool? {
    
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
  
  static func isDayTimeString(for dayTimeInformation: WeatherInformationDTO.DayTimeInformationDTO?, coordinates: WeatherInformationDTO.CoordinatesDTO) -> String? {
    guard let isDayTime = isDayTime(for: dayTimeInformation, coordinates: coordinates) else {
      return nil
    }
    return isDayTime ? R.string.localizable.dayTime() : R.string.localizable.nightTime()
  }
  
  static func dayCycleTimeStrings(for dayTimeInformation: WeatherInformationDTO.DayTimeInformationDTO?, coordinates: WeatherInformationDTO.CoordinatesDTO) -> DayCycleLocalizedTimeStrings? {
    
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

private extension MeteorologyInformationConversionWorker {
  
  static func dayCycleDateComponents(for dayTimeInformation: WeatherInformationDTO.DayTimeInformationDTO?, coordinates: WeatherInformationDTO.CoordinatesDTO) -> DayCycleDateComponents? {
    
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

// MARK: - Helper Extensions

private extension NumberFormatter {
  func string(from double: Double) -> String? {
    string(from: double as NSNumber)
  }
}

private extension Double {
  var toCardinalDirectionString: String? {
    MeteorologyInformationConversionWorker.WindDirection(degrees: self)?.stringValue
  }
}
