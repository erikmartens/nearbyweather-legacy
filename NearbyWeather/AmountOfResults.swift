//
//  AmountOfResults.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 16.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

enum AmountOfResultsWrappedEnum: Int, CaseIterable, Codable {
  case ten = 10
  case twenty = 20
  case thirty = 30
  case forty = 40
  case fifty = 50
}

class AmountOfResults: Codable, PreferencesOption {
  
  static let availableOptions = [AmountOfResults(value: .ten),
                                 AmountOfResults(value: .twenty),
                                 AmountOfResults(value: .thirty),
                                 AmountOfResults(value: .forty),
                                 AmountOfResults(value: .fifty)]
  
  typealias PreferencesOptionType = AmountOfResultsWrappedEnum
  
  private lazy var count = {
    return AmountOfResultsWrappedEnum.allCases.count
  }()
  
  var value: AmountOfResultsWrappedEnum
  
  required init(value: AmountOfResultsWrappedEnum) {
    self.value = value
  }
  
  required convenience init?(rawValue: Int) {
    guard let value = AmountOfResultsWrappedEnum(rawValue: rawValue) else {
      return nil
    }
    self.init(value: value)
  }
  
  var stringValue: String {
    return "\(value.rawValue) \(R.string.localizable.results())"
  }
  
  var integerValue: Int {
    return value.rawValue
  }
}
