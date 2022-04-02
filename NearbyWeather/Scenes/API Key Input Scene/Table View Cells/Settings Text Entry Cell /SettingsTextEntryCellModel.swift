//
//  SettingsTextEntryCellModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import Foundation

struct SettingsTextEntryCellModel {
  let textFieldPlaceholderText: String?
  let textFieldText: String?
  
  init(
    textFieldPlaceholderText: String? = nil,
    textFieldText: String? = nil
  ) {
    self.textFieldPlaceholderText = textFieldPlaceholderText
    self.textFieldText = textFieldText
  }
}
