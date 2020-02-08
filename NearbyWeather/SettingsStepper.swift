//
//  SettingsStepper.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 08.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

class SettingsStepper: Stepper {}

extension SettingsStepper {
  
  func requestRouting(toStep step: SettingsStep) {
    emitStep(step, type: SettingsStep.self)
  }
}
