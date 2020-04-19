//
//  ListStepper.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxCocoa
import RxFlow

enum ListStep: Step {
  case list
  case emptyList
  case weatherDetails(identifier: Int?, isBookmark: Bool)
  case dismissChildFlow
}

final class ListStepper: Stepper {
  
  var steps = PublishRelay<Step>()
  
  var initialStep: Step {
    WeatherDataService.shared.hasDisplayableData
      ? ListStep.list
      : ListStep.emptyList
  }
}
