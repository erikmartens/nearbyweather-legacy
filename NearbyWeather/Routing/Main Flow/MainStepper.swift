//
//  MainStepper.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxCocoa
import RxFlow

enum MainStep: Step {
  case main
}

final class MainStepper: Stepper {
  
  var steps = PublishRelay<Step>()
  
  let initialStep: Step = MainStep.main
}
