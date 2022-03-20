//
//  SettingsImagedDualLabelSubtitleCellModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 20.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import UIKit

struct SettingsImagedDualLabelSubtitleCellModel {
  let symbolImageBackgroundColor: UIColor?
  let symbolImage: UIImage?
  let contentLabelText: String?
  let descriptionLabelText: String?
  let isSelectable: Bool?
  let isDisclosable: Bool?
  
  init(
    symbolImageBackgroundColor: UIColor? = nil,
    symbolImage: UIImage? = nil,
    contentLabelText: String? = nil,
    descriptionLabelText: String? = nil,
    selectable: Bool? = nil,
    disclosable: Bool? = nil
  ) {
    self.symbolImageBackgroundColor = symbolImageBackgroundColor
    self.symbolImage = symbolImage
    self.contentLabelText = contentLabelText
    self.descriptionLabelText = descriptionLabelText
    self.isSelectable = selectable
    self.isDisclosable = disclosable
  }
}

