//
//  WeatherStationMeteorologyDetailsHeaderDualLabelSubCellModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 02.04.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import UIKit

struct WeatherStationMeteorologyDetailsHeaderDualLabelSubCellModel {
  
  let lhsText: String?
  let rhsText: String?
  let backgroundColor: UIColor
  
  init(
    lhsText: String? = nil,
    rhsText: String? = nil,
    backgroundColor: UIColor = Constants.Theme.Color.ViewElement.WeatherInformation.colorBackgroundDay
  ) {
    self.lhsText = lhsText
    self.rhsText = rhsText
    self.backgroundColor = backgroundColor
  }
}
