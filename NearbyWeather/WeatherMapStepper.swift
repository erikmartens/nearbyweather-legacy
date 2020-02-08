//
//  WeatherMapStepper.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 08.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

class WeatherMapStepper: Stepper {}

extension WeatherMapStepper {
  
  func routeToWeatherDetails(for identifier: Int?) {
    let step = WeatherMapStep.weatherDetails(identifier: identifier)
    super.emitStep(step, type: WeatherMapStep.self)
  }
  
  func dismissWeatherDetails() {
    let step = WeatherDetailStep.dismiss
    super.emitStep(step, type: WeatherDetailStep.self)
  }
}
