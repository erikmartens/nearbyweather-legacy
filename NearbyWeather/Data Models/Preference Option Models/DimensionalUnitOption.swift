//
//  DistanceSpeedUnit.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 16.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

enum DimensionalUnitOptionValue: Int, CaseIterable, Codable, Equatable {
  case metric
  case imperial
  
  var title: String {
    switch self {
    case .metric: return R.string.localizable.metric()
    case .imperial: return R.string.localizable.imperial()
    }
  }
}

struct DimensionalUnitOption: Codable, Equatable, PreferencesOption {
  static let availableOptions = [DimensionalUnitOption(value: .metric),
                                 DimensionalUnitOption(value: .imperial)]
  
  typealias PreferencesOptionType = DimensionalUnitOptionValue
  
  private lazy var count = {
    DimensionalUnitOptionValue.allCases.count
  }()
  
  var value: DimensionalUnitOptionValue
  
  init(value: DimensionalUnitOptionValue) {
    self.value = value
  }
  
  init?(rawValue: Int) {
    guard let value = DimensionalUnitOptionValue(rawValue: rawValue) else {
      return nil
    }
    self.init(value: value)
  }
  
  var stringValue: String {
    value.title
  }
}
