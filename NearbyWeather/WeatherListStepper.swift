//
//  WeatherListStepper.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 08.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

class WeatherListStepper: Stepper {}

extension WeatherListStepper {
  
  func routeToWeatherDetails(for identifier: Int?) {
    let step = WeatherListStep.weatherDetails(identifier: identifier)
    super.emitStep(step, type: WeatherListStep.self)
  }
  
  func dismissWeatherDetails() {
    let step = WeatherDetailStep.dismiss
    super.emitStep(step, type: WeatherDetailStep.self)
  }
}
