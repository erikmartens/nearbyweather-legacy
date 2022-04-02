//
//  ApiKeyInputStepper.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxCocoa
import RxFlow

enum ApiKeyInputStep: Step {
  case apiKeyInput
  case end
}

final class ApiKeyInputStepper: Stepper {
  
  var steps = PublishRelay<Step>()
  
  var initialStep: Step = ApiKeyInputStep.apiKeyInput
}
