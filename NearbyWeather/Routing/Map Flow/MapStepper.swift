//
//  MapStepper.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxCocoa
import RxFlow

enum MapStep: Step { // TODO: rename to WeatherMapStep
  case map
  case weatherDetails2(identity: PersistencyModelIdentity)
  case changeMapTypeAlert(selectionDelegate: MapTypeSelectionAlertDelegate)
  case changeMapTypeAlertAdapted(selectionDelegate: MapTypeSelectionAlertDelegate, currentSelectedOptionValue: MapTypeValue)
  case changeAmountOfResultsAlert(selectionDelegate: AmountOfResultsSelectionAlertDelegate)
  case changeAmountOfResultsAlertAdapted(selectionDelegate: AmountOfResultsSelectionAlertDelegate, currentSelectedOptionValue: AmountOfResultsValue)
  case focusOnLocationAlert(selectionDelegate: FocusOnLocationSelectionAlertDelegate)
  case focusOnLocationAlertAdapted(selectionDelegate: FocusOnLocationSelectionAlertDelegate, weatherInformationDTOs: [WeatherInformationDTO])
  case dismissChildFlow
}

final class MapStepper: Stepper { // TODO: rename to WeatherMapStepper
  
  var steps = PublishRelay<Step>()
  
  let initialStep: Step = MapStep.map
}
