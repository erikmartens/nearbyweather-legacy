//
//  ManageBookmarksStepper.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 15.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxCocoa
import RxFlow

enum ManageBookmarksStep: Step {
  case manageBookmarks
  case end
}

final class ManageBookmarksStepper: Stepper {
  
  var steps = PublishRelay<Step>()
  
  var initialStep: Step = ManageBookmarksStep.manageBookmarks
}
