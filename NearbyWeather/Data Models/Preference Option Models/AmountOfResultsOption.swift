//
//  AmountOfResults.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 16.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit

enum AmountOfResultsOptionValue: Int, CaseIterable, Codable, Equatable {
  case ten = 10
  case twenty = 20
  case thirty = 30
  case forty = 40
  case fifty = 50
}

struct AmountOfResultsOption: Codable, Equatable, PreferencesOption {
  
  static let availableOptions = [AmountOfResultsOption(value: .ten),
                                 AmountOfResultsOption(value: .twenty),
                                 AmountOfResultsOption(value: .thirty),
                                 AmountOfResultsOption(value: .forty),
                                 AmountOfResultsOption(value: .fifty)]
  
  typealias PreferencesOptionType = AmountOfResultsOptionValue
  
  private lazy var count = {
    AmountOfResultsOptionValue.allCases.count
  }()
  
  var value: AmountOfResultsOptionValue
  
  init(value: AmountOfResultsOptionValue) {
    self.value = value
  }
  
 init?(rawValue: Int) {
    guard let value = AmountOfResultsOptionValue(rawValue: rawValue) else {
      return nil
    }
    self.init(value: value)
  }
  
  var stringValue: String {
    value.rawValue.append(contentsOf: R.string.localizable.results(), delimiter: .space)
  }
  
  var integerValue: Int {
    value.rawValue
  }
}
