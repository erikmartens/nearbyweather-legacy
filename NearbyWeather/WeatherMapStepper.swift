//
//  WeatherMapStepper.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 08.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

final class WeatherMapStepper: Stepper {}

extension WeatherMapStepper {
  
  func requestRouting(toStep step: WeatherMapStep) {
    emitStep(step, type: WeatherMapStep.self)
  }
}
