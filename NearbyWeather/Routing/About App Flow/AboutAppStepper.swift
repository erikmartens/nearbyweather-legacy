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
  case sendEmail(recipients: [String], subject: String, message: String)
  case safariViewController(url: URL)
  case externalApp(url: URL)
  case end
}

final class AboutAppStepper: Stepper {
  
  var steps = PublishRelay<Step>()
  
  var initialStep: Step = AboutAppStep.aboutApp
}
