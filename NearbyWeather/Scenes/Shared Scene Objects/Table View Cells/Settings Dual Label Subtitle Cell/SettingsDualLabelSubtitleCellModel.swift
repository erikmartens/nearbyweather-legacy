//
//  SettingsDualLabelSubtitleCellModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import Foundation

struct SettingsDualLabelSubtitleCellModel {
  let contentLabelText: String?
  let subtitleLabelText: String?
  let isSelectable: Bool?
  let isDisclosable: Bool?
  
  init(
    contentLabelText: String? = nil,
    subtitleLabelText: String? = nil,
    selectable: Bool? = nil,
    disclosable: Bool? = nil
  ) {
    self.contentLabelText = contentLabelText
    self.subtitleLabelText = subtitleLabelText
    self.isSelectable = selectable
    self.isDisclosable = disclosable
  }
}
