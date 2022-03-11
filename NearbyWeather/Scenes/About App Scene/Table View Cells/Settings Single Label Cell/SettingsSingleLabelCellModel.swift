//
//  SettingsSingleLabelCellModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import Foundation

struct SettingsSingleLabelCellModel {
  let labelText: String?
  let isSelectable: Bool?
  let isDisclosable: Bool?
  
  init(
    labelText: String? = nil,
    selectable: Bool? = nil,
    disclosable: Bool? = nil
  ) {
    self.labelText = labelText
    self.isSelectable = selectable
    self.isDisclosable = disclosable
  }
}
