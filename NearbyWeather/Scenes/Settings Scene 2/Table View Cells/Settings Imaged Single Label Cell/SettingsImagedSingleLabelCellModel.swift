//
//  SettingsImagedSingleLabelCellModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 06.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import UIKit

struct SettingsImagedSingleLabelCellModel {
  let symbolImageBackgroundColor: UIColor?
  let symbolImage: UIImage?
  let labelText: String?
  let isSelectable: Bool?
  let isDisclosable: Bool?
  
  init(
    symbolImageBackgroundColor: UIColor? = nil,
    symbolImage: UIImage? = nil,
    labelText: String? = nil,
    selectable: Bool? = nil,
    disclosable: Bool? = nil
  ) {
    self.symbolImageBackgroundColor = symbolImageBackgroundColor
    self.symbolImage = symbolImage
    self.labelText = labelText
    self.isSelectable = selectable
    self.isDisclosable = disclosable
  }
}
