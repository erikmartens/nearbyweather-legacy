//
//  DistanceSpeedUnit.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 16.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

enum DistanceSpeedUnitWrappedEnum: Int, CaseIterable, Codable {
  case kilometres
  case miles
}

struct DistanceSpeedUnit: Codable, PreferencesOption {
  static let availableOptions = [DistanceSpeedUnit(value: .kilometres),
                                 DistanceSpeedUnit(value: .miles)]
  
  typealias PreferencesOptionType = DistanceSpeedUnitWrappedEnum
  
  private lazy var count = {
    return DistanceSpeedUnitWrappedEnum.allCases.count
  }()
  
  var value: DistanceSpeedUnitWrappedEnum
  
  init(value: DistanceSpeedUnitWrappedEnum) {
    self.value = value
  }
  
  init?(rawValue: Int) {
    guard let value = DistanceSpeedUnitWrappedEnum(rawValue: rawValue) else {
      return nil
    }
    self.init(value: value)
  }
  
  var stringValue: String {
    switch value {
    case .kilometres: return "\(R.string.localizable.metric())"
    case .miles: return "\(R.string.localizable.imperial())"
    }
  }
}
