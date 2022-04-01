//
//  SettingsImagedDualLabelCellModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 06.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import UIKit

struct SettingsImagedDualLabelCellModel {
  let symbolImageBackgroundColor: UIColor?
  let symbolImageName: String?
  let contentLabelText: String?
  let descriptionLabelText: String?
  let isSelectable: Bool?
  let isDisclosable: Bool?
  
  init(
    symbolImageBackgroundColor: UIColor? = nil,
    symbolImageName: String? = nil,
    contentLabelText: String? = nil,
    descriptionLabelText: String? = nil,
    selectable: Bool? = nil,
    disclosable: Bool? = nil
  ) {
    self.symbolImageBackgroundColor = symbolImageBackgroundColor
    self.symbolImageName = symbolImageName
    self.contentLabelText = contentLabelText
    self.descriptionLabelText = descriptionLabelText
    self.isSelectable = selectable
    self.isDisclosable = disclosable
  }
}
