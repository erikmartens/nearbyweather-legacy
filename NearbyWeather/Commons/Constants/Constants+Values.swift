//
//  Constants+Values.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 30.01.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

extension Constants {
  enum Values {}
}

extension Constants.Values {
  
  enum AppVersion {
    static let kVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? Constants.Messages.kUndefined
    static let kBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? Constants.Messages.kUndefined
    static let kVersionBuildString = "Version \(kVersion) Build #\(kBuild)"
  }
  
  enum TemperatureName {
    static let kCelsius = "Celsius"
    static let kFahrenheit = "Fahrenheit"
    static let kKelvin = "Kelvin"
  }
  
  enum TemperatureUnit {
    static let kCelsius = "°C"
    static let kFahrenheit = "°F"
    static let kKelvin = "K"
  }
}

extension Constants.Values {
  enum ApiKey {}
}

extension Constants.Values.ApiKey {
  static let kOpenWeatherMapApiKeyLength = 32
}
