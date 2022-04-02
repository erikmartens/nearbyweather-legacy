//
//  ListTypeOption.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

enum ListTypeOptionValue: Int, CaseIterable, Codable, Equatable {
  case bookmarked
  case nearby
  
  var title: String {
    switch self {
    case .bookmarked:
      return R.string.localizable.bookmarked()
    case .nearby:
      return R.string.localizable.nearby()
    }
  }
}

struct ListTypeOption: Codable, Equatable, PreferencesOption {
  
  static let availableOptions = [ListTypeOption(value: .bookmarked),
                                 ListTypeOption(value: .nearby)]
  
  typealias PreferencesOptionType = ListTypeOptionValue
  
  private lazy var count = {
    ListTypeOptionValue.allCases.count
  }()
  
  var value: ListTypeOptionValue
  
  init(value: ListTypeOptionValue) {
    self.value = value
  }
  
  init?(rawValue: Int) {
    guard let value = ListTypeOptionValue(rawValue: rawValue) else {
      return nil
    }
    self.init(value: value)
  }
  
  var stringValue: String {
    value.title
  }
}
