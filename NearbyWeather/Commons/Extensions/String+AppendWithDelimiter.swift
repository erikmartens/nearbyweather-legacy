//
//  String+AppendWithDelimiter.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 12.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

extension String {
  
  func append(contentsOf string: String?, delimiter: String) -> String {
    guard let string = string else {
      return self
    }
    guard !self.isEmpty else {
      return string
    }
    return "\(self)\(delimiter)\(string)"
  }
  
  func ifEmpty(justReturn string: String?) -> String? {
    guard !isEmpty else {
      return string
    }
    return self
  }
}
