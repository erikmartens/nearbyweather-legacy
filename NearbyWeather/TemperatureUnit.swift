//
//  TemperatureUnit.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 16.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

enum TemperatureUnitWrappedEnum: Int, CaseIterable, Codable {
  case celsius
  case fahrenheit
  case kelvin
}

struct TemperatureUnit: Codable, PreferencesOption {
  static let availableOptions = [TemperatureUnit(value: .celsius),
                                 TemperatureUnit(value: .fahrenheit),
                                 TemperatureUnit(value: .kelvin)]
  
  typealias PreferencesOptionType = TemperatureUnitWrappedEnum
  
  private lazy var count: Int = {
    return TemperatureUnitWrappedEnum.allCases.count
  }()
  
  var value: TemperatureUnitWrappedEnum
  
  init(value: TemperatureUnitWrappedEnum) {
    self.value = value
  }
  
  init?(rawValue: Int) {
    guard let value = TemperatureUnitWrappedEnum(rawValue: rawValue) else {
      return nil
    }
    self.init(value: value)
  }
  
  var stringValue: String {
    switch value {
    case .celsius: return Constants.Values.TemperatureName.kCelsius
    case .fahrenheit: return Constants.Values.TemperatureName.kFahrenheit
    case .kelvin: return Constants.Values.TemperatureName.kKelvin
    }
  }
  
  var abbreviation: String {
    switch value {
    case .celsius: return Constants.Values.TemperatureUnit.kCelsius
    case .fahrenheit: return Constants.Values.TemperatureUnit.kFahrenheit
    case .kelvin: return Constants.Values.TemperatureUnit.kKelvin
    }
  }
}
