//
//  Step.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 08.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

protocol StepProtocol {
  static var identifier: String { get }
}

extension StepProtocol {
  static var identifier: String {
    return String(describing: self)
  }
}

enum Step: StepProtocol {
  case none
}
