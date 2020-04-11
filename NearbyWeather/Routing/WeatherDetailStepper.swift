//
//  WeatherDetailStepper.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 08.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

final class WeatherDetailStepper: Stepper {}

extension WeatherDetailStepper {
  
  func requestRouting(toStep step: WeatherDetailStep) {
    emitStep(step, type: WeatherDetailStep.self)
  }
}
