//
//  RootStepper.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxFlow
import RxCocoa

enum RootStep: Step {
  case main
  case welcome
  case dimissWelcome
}

class RootStepper: Stepper {
  
  var steps = PublishRelay<Step>()
  
  var initialStep: Step {
    guard UserDefaults.standard.value(forKey: Constants.Keys.UserDefaults.kNearbyWeatherApiKeyKey) != nil else {
      return RootStep.welcome
    }
    return RootStep.main
  }
}
