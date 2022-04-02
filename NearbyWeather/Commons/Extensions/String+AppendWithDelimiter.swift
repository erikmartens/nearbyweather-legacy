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
  case colon
  case semicolon
  case custom(string: String)
  
  var stringValue: String {
    switch self {
    case .none:
      return ""
    case .space:
      return " "
    case .comma:
      return ", "
    case .colon:
      return ": "
    case .semicolon:
      return "; "
    case let .custom(string):
      return string
    }
  }
}

enum Encasing {
  case none
  case quotes
  case roundBrackets
  case squareBrackets
  case curlyBrackets
}

private extension String {
  
  func encase(using encasing: Encasing) -> String {
    switch encasing {
    case .none:
      return self
    case .quotes:
      return "\"\(self)\""
    case .roundBrackets:
      return "(\(self))"
    case .squareBrackets:
      return "[\(self)]"
    case .curlyBrackets:
      return "{\(self)}"
    }
  }
}

extension String {
  
  static func begin(with string: String? = nil, defaultTo replacement: String = "") -> String {
    string ?? replacement
  }
  
  static func begin(with convertible: CustomStringConvertible?, defaultTo replacement: String = "") -> String {
    guard let convertible = convertible else {
      return replacement
    }
    return String(describing: convertible)
  }
  
  func append(contentsOf string: String?, encasing: Encasing = .none, delimiter: Delimiter, emptyIfPredecessorWasEmpty: Bool = false) -> String {
    guard let string = string else {
      return self
    }
    if isEmpty {
      if emptyIfPredecessorWasEmpty {
        return ""
      }
      return string
    }
    return "\(self)\(delimiter.stringValue)\(string.encase(using: encasing))"
  }
  
  func append(contentsOfConvertible convertible: CustomStringConvertible?, encasing: Encasing = .none, delimiter: Delimiter, emptyIfPredecessorWasEmpty: Bool = false) -> String {
    guard let convertible = convertible else {
      return self
    }
    return append(contentsOf: String(describing: convertible), encasing: encasing, delimiter: delimiter, emptyIfPredecessorWasEmpty: emptyIfPredecessorWasEmpty)
  }
  
  func ifEmpty(justReturn string: String?) -> String? {
    if isEmpty {
      return string
    }
    return self
  }
}

extension CustomStringConvertible {
  
  func append(contentsOf string: String?, encasing: Encasing = .none, delimiter: Delimiter) -> String {
    guard let string = string else {
      return String(describing: self)
    }
    guard !String(describing: self).isEmpty else {
      return string
    }
    return "\(String(describing: self))\(delimiter.stringValue)\(string.encase(using: encasing))"
  }
  
  func append(contentsOfConvertible convertible: CustomStringConvertible?, encasing: Encasing = .none, delimiter: Delimiter) -> String {
    guard let convertible = convertible else {
      return String(describing: self)
    }
    return append(contentsOf: String(describing: convertible), encasing: encasing, delimiter: delimiter)
  }
}
