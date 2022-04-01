//
//  SettingsImagedSingleLabelToggleCellModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 06.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import UIKit

struct SettingsImagedSingleLabelToggleCellModel {
  let symbolImageBackgroundColor: UIColor?
  let symbolImageName: String?
  let labelText: String?
  let isToggleOn: Bool?
  
  init(
    symbolImageBackgroundColor: UIColor? = nil,
    symbolImageName: String? = nil,
    labelText: String? = nil,
    isToggleOn: Bool? = nil
  ) {
    self.symbolImageBackgroundColor = symbolImageBackgroundColor
    self.symbolImageName = symbolImageName
    self.labelText = labelText
    self.isToggleOn = isToggleOn
  }
}
