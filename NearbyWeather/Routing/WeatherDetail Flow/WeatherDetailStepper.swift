//
//  WeatherDetailStepper.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxCocoa
import RxFlow

enum WeatherDetailStep: Step {
  case weatherDetail
  case dismiss
}

final class WeatherDetailStepper: Stepper {
  
  var steps = PublishRelay<Step>()
  
  var initialStep: Step = WeatherDetailStep.weatherDetail
}
