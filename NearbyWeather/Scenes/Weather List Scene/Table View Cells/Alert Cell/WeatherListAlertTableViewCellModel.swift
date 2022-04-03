//
//  WeatherInformationAlertTableViewCellModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 05.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import UIKit

struct WeatherListAlertTableViewCellModel {
  let alertTitle: String?
  let alertDescription: String?
  
  init(
    alertTitle: String? = nil,
    alertDescription: String? = nil
  ) {
    self.alertTitle = alertTitle
    self.alertDescription = alertDescription
  }
}
