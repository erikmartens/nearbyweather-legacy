//
//  MapStepper.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxCocoa
import RxFlow

enum WeatherMapStep: Step {
  case map
  case weatherDetails2(identity: PersistencyModelIdentity)
  case changeMapTypeAlert(selectionDelegate: MapTypeSelectionAlertDelegate)
  case changeMapTypeAlertAdapted(selectionDelegate: MapTypeSelectionAlertDelegate, currentSelectedOptionValue: MapTypeOptionValue)
  case changeAmountOfResultsAlert(selectionDelegate: AmountOfResultsSelectionAlertDelegate)
  case changeAmountOfResultsAlertAdapted(selectionDelegate: AmountOfResultsSelectionAlertDelegate, currentSelectedOptionValue: AmountOfResultsOptionValue)
  case focusOnLocationAlert(selectionDelegate: FocusOnLocationSelectionAlertDelegate)
  case focusOnLocationAlertAdapted(selectionDelegate: FocusOnLocationSelectionAlertDelegate, weatherInformationDTOs: [WeatherInformationDTO])
  case dismissChildFlow
}

final class WeatherMapStepper: Stepper {
  
  var steps = PublishRelay<Step>()
  
  let initialStep: Step = WeatherMapStep.map
}
