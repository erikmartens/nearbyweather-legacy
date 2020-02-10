//
//  WeatherListStepper.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 08.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

final class WeatherListStepper: Stepper {}

extension WeatherListStepper {
  
  func requestRouting(toStep step: WeatherListStep) {
    emitStep(step, type: WeatherListStep.self)
  }
}
