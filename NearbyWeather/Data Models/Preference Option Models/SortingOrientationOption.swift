//
//  SortingOrientation.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 16.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

enum SortingOrientationOptionValue: Int, CaseIterable, Codable, Equatable {
  case name
  case temperature
  case distance
  
  var title: String {
    switch self {
    case .name: return R.string.localizable.sortByName()
    case .temperature: return R.string.localizable.sortByTemperature()
    case .distance: return R.string.localizable.sortByDistance()
    }
  }
}

struct SortingOrientationOption: Codable, Equatable, PreferencesOption {
  static let availableOptions = [SortingOrientationOption(value: .name),
                                 SortingOrientationOption(value: .temperature),
                                 SortingOrientationOption(value: .distance)]
  
  typealias PreferencesOptionType = SortingOrientationOptionValue
  
  private lazy var count = {
    SortingOrientationOptionValue.allCases.count
  }
  
  var value: SortingOrientationOptionValue
  
  init(value: SortingOrientationOptionValue) {
    self.value = value
  }
  
  init?(rawValue: Int) {
    guard let value = SortingOrientationOptionValue(rawValue: rawValue) else {
      return nil
    }
    self.init(value: value)
  }
  
  var stringValue: String {
    value.title
  }
}
