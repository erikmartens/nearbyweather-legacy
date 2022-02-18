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
  case weatherDetails2(identity: PersistencyModelIdentity)
  case changeMapTypeAlert(selectionDelegate: MapTypeSelectionAlertDelegate, currentSelectedOptionValue: MapTypeValue)
  case changeAmountOfResultsAlert(selectionDelegate: AmountOfResultsSelectionAlertDelegate, currentSelectedOptionValue: AmountOfResultsValue)
  case focusOnLocationAlert(selectionDelegate: FocusOnLocationSelectionAlertDelegate)
  case focusOnLocationAlertAdapted(selectionDelegate: FocusOnLocationSelectionAlertDelegate, weatherInformationDTOs: [WeatherInformationDTO])
  case dismissChildFlow
}

final class MapStepper: Stepper {
  
  var steps = PublishRelay<Step>()
  
  let initialStep: Step = MapStep.map
}
