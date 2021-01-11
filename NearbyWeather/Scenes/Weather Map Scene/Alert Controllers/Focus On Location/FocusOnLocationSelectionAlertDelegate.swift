//
//  FocusOnLocationSelectionAlertDelegate.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import CoreLocation

enum FocusOnLocationOption {
  case userLocation
  case weatherStation(location: CLLocation?)
}

protocol FocusOnLocationSelectionAlertDelegate: class {
  func didSelectFocusOnLocationOption(_ option: FocusOnLocationOption)
}
