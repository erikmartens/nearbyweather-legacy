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
  case manageBookmarks
  case addBookmark
  case changePreferredBookmarkAlert(selectionDelegate: PreferredBookmarkSelectionAlertDelegate)
  case changePreferredBookmarkAlertAdapted(selectionDelegate: PreferredBookmarkSelectionAlertDelegate, selectedOptionValue: PreferredBookmarkOption?, boomarkedLocations: [WeatherStationDTO])
  case changeTemperatureUnitAlert(selectionDelegate: TemperatureUnitSelectionAlertDelegate)
  case changeTemperatureUnitAlertAdapted(selectionDelegate: TemperatureUnitSelectionAlertDelegate, selectedOptionValue: TemperatureUnitOptionValue)
  case changeDimensionalUnitAlert(selectionDelegate: DimensionalUnitSelectionAlertDelegate)
  case changeDimensionalUnitAlertAdapted(selectionDelegate: DimensionalUnitSelectionAlertDelegate, selectedOptionValue: DimensionalUnitOptionValue)
  case webBrowser(url: URL)
  case pop
}

final class SettingsStepper: Stepper {
  
  var steps = PublishRelay<Step>()
  
  var initialStep: Step = SettingsStep.settings
}
