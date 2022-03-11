//
//  SettingsSingleLabelDualButtonCellModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import Foundation

struct SettingsSingleLabelDualButtonCellModel {
  let contentLabelText: String?
  let lhsButtonTitle: String?
  let rhsButtonTitle: String?
  
  init(
    contentLabelText: String? = nil,
    lhsButtonTitle: String? = nil,
    rhsButtonTitle: String? = nil
  ) {
    self.contentLabelText = contentLabelText
    self.lhsButtonTitle = lhsButtonTitle
    self.rhsButtonTitle = rhsButtonTitle
  }
}
