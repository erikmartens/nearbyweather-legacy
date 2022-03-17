//
//  WeatherDetailStepper.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxCocoa
import RxFlow

enum WeatherStationMeteorologyDetailsStep: Step {
  case weatherStationMeteorologyDetails
  case end
}

final class WeatherStationMeteorologyDetailsStepper: Stepper {
  
  var steps = PublishRelay<Step>()
  
  var initialStep: Step = WeatherStationMeteorologyDetailsStep.weatherStationMeteorologyDetails
}
