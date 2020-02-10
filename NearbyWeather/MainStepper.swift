//
//  MainStepper.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 08.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

final class MainStepper: Stepper {}

extension MainStepper {
  
  func requestRouting(toStep step: MainStep) {
    emitStep(step, type: MainStep.self)
  }
}
