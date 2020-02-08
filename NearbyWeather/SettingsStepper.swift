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
  
  func routeToAboutApp() {
    super.emitStep(SettingsStep.about, type: SettingsStep.self)
  }
  
  func routeToApiKeyEdit() {
    super.emitStep(SettingsStep.apiKeyEdit, type: SettingsStep.self)
  }
}
