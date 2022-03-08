//
//  ShowTemperatureOnAppIconOption.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 08.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import Foundation

enum ShowTemperatureOnAppIconValue: Int, CaseIterable, Codable, Equatable {
  case no
  case yes
}

struct ShowTemperatureOnAppIconOption: Codable, Equatable, PreferencesOption {
  static let availableOptions = [ShowTemperatureOnAppIconOption(value: .no),
                                 ShowTemperatureOnAppIconOption(value: .yes)]
  
  typealias PreferencesOptionType = ShowTemperatureOnAppIconValue
  
  private lazy var count = {
    ShowTemperatureOnAppIconValue.allCases.count
  }
  
  var value: ShowTemperatureOnAppIconValue
  
  init(value: ShowTemperatureOnAppIconValue) {
    self.value = value
  }
  
  init?(rawValue: Int) {
    guard let value = ShowTemperatureOnAppIconValue(rawValue: rawValue) else {
      return nil
    }
    self.init(value: value)
  }
  
  var rawRepresentableValue: Bool {
    switch value {
    case .no: return false
    case .yes: return true
    }
  }
}
