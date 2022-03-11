//
//  AboutAppStepper.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxCocoa
import RxFlow

enum AboutAppStep: Step {
  case aboutApp
  case safariViewController(url: URL)
  case externalApp(url: URL)
  case dismiss
}

final class AboutAppStepper: Stepper {
  
  var steps = PublishRelay<Step>()
  
  var initialStep: Step = AboutAppStep.aboutApp
}
