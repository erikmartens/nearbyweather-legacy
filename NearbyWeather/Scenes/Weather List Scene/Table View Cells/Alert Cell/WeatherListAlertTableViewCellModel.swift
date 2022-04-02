//
//  WeatherInformationAlertTableViewCellModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 05.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import UIKit

struct WeatherListAlertTableViewCellModel {
  let backgroundColor = Constants.Theme.Color.ViewElement.alert
  let alertImage = UIImage() // TODO: fix (prolly gets deleted anyway, when rebuilding the cell)
  let alertImageTintColor = Constants.Theme.Color.ViewElement.Label.titleLight
  let alertInformationText: String?
  let alertInformationTextColor = Constants.Theme.Color.ViewElement.Label.titleLight
  
  init(
    alertInformationText: String? = nil
  ) {
    self.alertInformationText = alertInformationText
  }
}
