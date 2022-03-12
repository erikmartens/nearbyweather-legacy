//
//  AddBookmarkStepper.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 12.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxCocoa
import RxFlow

enum AddBookmarkStep: Step {
  case addBookmark
  case end
}

final class AddBookmarkStepper: Stepper {
  
  var steps = PublishRelay<Step>()
  
  var initialStep: Step = AddBookmarkStep.addBookmark
}
