//
//  WelcomeStepper.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxCocoa
import RxFlow

enum WelcomeStep: Step {
  case setApiKey
  case setPermissions
  case dismiss
}

final class WelcomeStepper: Stepper {
  
  var steps = PublishRelay<Step>()
  
  let initialStep: Step = WelcomeStep.setApiKey
}
