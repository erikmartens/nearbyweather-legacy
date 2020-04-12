//
//  String+AppendWithDelimiter.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 12.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

enum Delimiter {
  case none
  case space
  case comma
  case custom(string: String)
  
  var stringValue: String {
    switch self {
    case .none:
      return ""
    case .space:
      return " "
    case .comma:
      return ", "
    case let .custom(string):
      return string
    }
  }
}

extension String {
  
  func append(contentsOf string: String?, delimiter: Delimiter) -> String {
    guard let string = string else {
      return self
    }
    guard !self.isEmpty else {
      return string
    }
    return "\(self)\(delimiter.stringValue)\(string)"
  }
  
  func append(contentsOfConvertible convertible: CustomStringConvertible?, delimiter: Delimiter) -> String {
    guard let convertible = convertible else {
      return self
    }
    return append(contentsOf: String(describing: convertible), delimiter: delimiter)
  }
  
  func ifEmpty(justReturn string: String?) -> String? {
    guard !isEmpty else {
      return string
    }
    return self
  }
}

extension CustomStringConvertible {
  
  func append(contentsOf string: String?, delimiter: Delimiter) -> String {
    guard let string = string else {
      return String(describing: self)
    }
    guard !String(describing: self).isEmpty else {
      return string
    }
    return "\(String(describing: self))\(delimiter.stringValue)\(string)"
  }
  
  func append(contentsOfConvertible convertible: CustomStringConvertible?, delimiter: Delimiter) -> String {
    guard let convertible = convertible else {
      return String(describing: self)
    }
    return append(contentsOf: String(describing: convertible), delimiter: delimiter)
  }
}
