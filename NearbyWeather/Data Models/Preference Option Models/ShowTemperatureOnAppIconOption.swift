//
//  ShowTemperatureOnAppIconOption.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 08.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import Foundation

enum ShowTemperatureOnAppIconOptionValue: Int, CaseIterable, Codable, Equatable {
  case no
  case yes
  
  var boolValue: Bool {
    switch self {
    case .no: return false
    case .yes: return true
    }
  }
}

struct ShowTemperatureOnAppIconOption: Codable, Equatable, PreferencesOption {
  static let availableOptions = [ShowTemperatureOnAppIconOption(value: .no),
                                 ShowTemperatureOnAppIconOption(value: .yes)]
  
  typealias PreferencesOptionType = ShowTemperatureOnAppIconOptionValue
  
  private lazy var count = {
    ShowTemperatureOnAppIconOptionValue.allCases.count
  }
  
  var value: ShowTemperatureOnAppIconOptionValue
  
  init(value: ShowTemperatureOnAppIconOptionValue) {
    self.value = value
  }
  
  init?(rawValue: Int) {
    guard let value = ShowTemperatureOnAppIconOptionValue(rawValue: rawValue) else {
      return nil
    }
    self.init(value: value)
  }
  
  var rawRepresentableValue: Bool {
    value.boolValue
  }
}
