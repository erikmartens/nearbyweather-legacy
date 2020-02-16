//
//  SortingOrientation.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 16.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

enum SortingOrientationWrappedEnum: Int, CaseIterable, Codable {
  case name
  case temperature
  case distance
}

struct SortingOrientation: Codable, PreferencesOption {
  static let availableOptions = [SortingOrientation(value: .name),
                                 SortingOrientation(value: .temperature),
                                 SortingOrientation(value: .distance)]
  
  typealias PreferencesOptionType = SortingOrientationWrappedEnum
  
  private lazy var count = {
    return SortingOrientationWrappedEnum.allCases.count
  }
  
  var value: SortingOrientationWrappedEnum
  
  init(value: SortingOrientationWrappedEnum) {
    self.value = value
  }
  
  init?(rawValue: Int) {
    guard let value = SortingOrientationWrappedEnum(rawValue: rawValue) else {
      return nil
    }
    self.init(value: value)
  }
  
  var stringValue: String {
    switch value {
    case .name: return R.string.localizable.sortByName()
    case .temperature: return R.string.localizable.sortByTemperature()
    case .distance: return R.string.localizable.sortByDistance()
    }
  }
}
