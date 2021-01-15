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
  
  static func begin(with string: String?, defaultTo replacement: String = "") -> String {
    string ?? replacement
  }
  
  static func begin(with convertible: CustomStringConvertible?, defaultTo replacement: String = "") -> String {
    guard let convertible = convertible else {
      return replacement
    }
    return String(describing: convertible)
  }
  
  func append(contentsOf string: String?, delimiter: Delimiter, emptyIfPredecessorWasEmpty: Bool = false) -> String {
    guard let string = string else {
      return self
    }
    if self.isEmpty {
      if emptyIfPredecessorWasEmpty {
        return ""
      }
      return string
    }
    return "\(self)\(delimiter.stringValue)\(string)"
  }
  
  func append(contentsOfConvertible convertible: CustomStringConvertible?, delimiter: Delimiter, emptyIfPredecessorWasEmpty: Bool = false) -> String {
    guard let convertible = convertible else {
      return self
    }
    return append(contentsOf: String(describing: convertible), delimiter: delimiter, emptyIfPredecessorWasEmpty: emptyIfPredecessorWasEmpty)
  }
  
  func ifEmpty(justReturn string: String?) -> String? {
    if isEmpty {
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
