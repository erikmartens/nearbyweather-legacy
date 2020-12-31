//
//  MapStepper.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxCocoa
import RxFlow

enum MapStep: Step {
  case map
  case weatherDetails(identifier: Int?, isBookmark: Bool)
  case dismissChildFlow
}

final class MapStepper: Stepper {
  
  var steps = PublishRelay<Step>()
  
  let initialStep: Step = MapStep.map
}
