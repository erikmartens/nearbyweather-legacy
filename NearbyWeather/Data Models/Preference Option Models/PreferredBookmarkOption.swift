//
//  PreferredBookmark.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 16.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

enum PreferredBookmarkOptionValue: Codable, Equatable {
  case notSet
  case set(weatherStationDto: WeatherStationDTO)
  
  var stationName: String {
    switch self {
    case .notSet: return R.string.localizable.none()
    case let .set(weatherStationDto): return weatherStationDto.name
    }
  }
  
  var stationIdentifier: Int? {
    switch self {
    case .notSet: return nil
    case let .set(weatherStationDto): return weatherStationDto.identifier
    }
  }
}

struct PreferredBookmarkOption: Codable, Equatable, PreferencesOption {
    
  typealias PreferencesOptionType = PreferredBookmarkOptionValue
  
  var value: PreferredBookmarkOptionValue
  
  init(value: PreferredBookmarkOptionValue) {
    self.value = value
  }
  
  init?(rawValue: Int) {
    return nil
  }
  
  var stringValue: String {
    value.stationName
  }
  
  var intValue: Int? {
    value.stationIdentifier
  }
}
