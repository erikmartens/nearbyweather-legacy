//
//  Array+SafeAppend.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

extension Array {
  
  mutating func appendSafe(_ element: Element?) {
    guard let element = element else { return }
    append(element)
  }
}
