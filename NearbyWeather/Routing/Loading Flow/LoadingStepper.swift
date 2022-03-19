//
//  LoadingStepper.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxCocoa
import RxFlow

enum LoadingStep: Step {
  case loading
}

final class LoadingStepper: Stepper {
  
  var steps = PublishRelay<Step>()
  
  let initialStep: Step = LoadingStep.loading
}
