//
//  WeatherInformationAlertTableViewCellModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 05.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import UIKit

struct WeatherInformationAlertTableViewCellModel {
  let backgroundColor = Constants.Theme.Color.ViewElement.alert
  let alertImage = R.image.exclamationMark()
  let alertImageTintColor = Constants.Theme.Color.ViewElement.title
  let alertInformationText: String?
  let alertInformationTextColor = Constants.Theme.Color.ViewElement.title
  
  init(
    alertInformationText: String? = nil
  ) {
    self.alertInformationText = alertInformationText
  }
}
