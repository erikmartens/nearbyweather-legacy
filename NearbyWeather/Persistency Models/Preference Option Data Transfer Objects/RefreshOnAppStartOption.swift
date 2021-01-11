//
//  RefreshOnAppStartOption.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 10.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import Foundation

enum RefreshOnAppStartValue: Int, CaseIterable, Codable {
  case no
  case yes
}

struct RefreshOnAppStartOption: Codable, PreferencesOption {
  static let availableOptions = [RefreshOnAppStartOption(value: .no),
                                 RefreshOnAppStartOption(value: .yes)]
  
  typealias PreferencesOptionType = RefreshOnAppStartValue
  
  private lazy var count = {
    RefreshOnAppStartValue.allCases.count
  }
  
  var value: RefreshOnAppStartValue
  
  init(value: RefreshOnAppStartValue) {
    self.value = value
  }
  
  init?(rawValue: Int) {
    guard let value = RefreshOnAppStartValue(rawValue: rawValue) else {
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
