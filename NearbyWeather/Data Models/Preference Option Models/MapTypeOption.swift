//
//  MapTypeOption.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import MapKit

enum MapTypeOptionValue: Int, CaseIterable, Codable, Equatable {
  case standard
  case satellite
  case hybrid
  
  var mkMapTypeOption: MKMapType {
    switch self {
    case .standard:
      return .standard
    case .satellite:
      return .satellite
    case .hybrid:
      return .hybrid
    }
  }
  
  var title: String {
    switch self {
    case .standard:
      return R.string.localizable.map_type_standard()
    case .satellite:
      return R.string.localizable.map_type_satellite()
    case .hybrid:
      return R.string.localizable.map_type_hybrid()
    }
  }
}

struct MapTypeOption: Codable, Equatable, PreferencesOption {
  static let availableOptions = [MapTypeOption(value: .standard),
                                 MapTypeOption(value: .satellite),
                                 MapTypeOption(value: .hybrid)]
  
  typealias PreferencesOptionType = MapTypeOptionValue
  
  private lazy var count = {
    MapTypeOptionValue.allCases.count
  }()
  
  var value: MapTypeOptionValue
  
  init(value: MapTypeOptionValue) {
    self.value = value
  }
  
  init?(rawValue: Int) {
    guard let value = MapTypeOptionValue(rawValue: rawValue) else {
      return nil
    }
    self.init(value: value)
  }
  
  var stringValue: String {
    value.title
  }
}
