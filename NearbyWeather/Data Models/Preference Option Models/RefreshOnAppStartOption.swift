//
//  RefreshOnAppStartOption.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 10.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import Foundation

enum RefreshOnAppStartOptionValue: Int, CaseIterable, Codable, Equatable {
  case no
  case yes
  
  var boolValue: Bool {
    switch self {
    case .no: return false
    case .yes: return true
    }
  }
}

struct RefreshOnAppStartOption: Codable, Equatable, PreferencesOption {
  static let availableOptions = [RefreshOnAppStartOption(value: .no),
                                 RefreshOnAppStartOption(value: .yes)]
  
  typealias PreferencesOptionType = RefreshOnAppStartOptionValue
  
  private lazy var count = {
    RefreshOnAppStartOptionValue.allCases.count
  }
  
  var value: RefreshOnAppStartOptionValue
  
  init(value: RefreshOnAppStartOptionValue) {
    self.value = value
  }
  
  init?(rawValue: Int) {
    guard let value = RefreshOnAppStartOptionValue(rawValue: rawValue) else {
      return nil
    }
    self.init(value: value)
  }
  
  var rawRepresentableValue: Bool {
    value.boolValue
  }
}
