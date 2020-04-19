//
//  SettingsStepper.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxCocoa
import RxFlow

enum SettingsStep: Step {
  case settings
  case about
  case apiKeyEdit
  case manageLocations
  case addLocation
  case webBrowser(url: URL)
}

final class SettingsStepper: Stepper {
  
  var steps = PublishRelay<Step>()
  
  var initialStep: Step = SettingsStep.settings
}
