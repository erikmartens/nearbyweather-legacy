//
//  TemperatureUnit.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 16.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

enum TemperatureUnitOptionValue: Int, CaseIterable, Codable, Equatable {
  case celsius
  case fahrenheit
  case kelvin
  
  var title: String {
    switch self {
    case .celsius: return Constants.Values.TemperatureName.kCelsius
    case .fahrenheit: return Constants.Values.TemperatureName.kFahrenheit
    case .kelvin: return Constants.Values.TemperatureName.kKelvin
    }
  }
  
  var abbreviation: String {
    switch self {
    case .celsius: return Constants.Values.TemperatureUnit.kCelsius
    case .fahrenheit: return Constants.Values.TemperatureUnit.kFahrenheit
    case .kelvin: return Constants.Values.TemperatureUnit.kKelvin
    }
  }
}

struct TemperatureUnitOption: Codable, Equatable, PreferencesOption {
  static let availableOptions = [TemperatureUnitOption(value: .celsius),
                                 TemperatureUnitOption(value: .fahrenheit),
                                 TemperatureUnitOption(value: .kelvin)]
  
  typealias PreferencesOptionType = TemperatureUnitOptionValue
  
  private lazy var count: Int = {
    TemperatureUnitOptionValue.allCases.count
  }()
  
  var value: TemperatureUnitOptionValue
  
  init(value: TemperatureUnitOptionValue) {
    self.value = value
  }
  
  init?(rawValue: Int) {
    guard let value = TemperatureUnitOptionValue(rawValue: rawValue) else {
      return nil
    }
    self.init(value: value)
  }
  
  var stringValue: String {
    value.title
  }
}
