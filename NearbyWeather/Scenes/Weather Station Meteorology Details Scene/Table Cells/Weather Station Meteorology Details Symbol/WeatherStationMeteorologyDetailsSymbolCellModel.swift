//
//  WeatherStationMeteorologyDetailsSymbolCellModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 02.04.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import UIKit

struct WeatherStationMeteorologyDetailsSymbolCellModel {
  let symbolImageName: String?
  let symbolImageRotationAngle: CGFloat?
  let contentLabelText: String?
  let descriptionLabelText: String?
  let isSelectable: Bool?
  let isDisclosable: Bool?
  
  init(
    symbolImageName: String? = nil,
    symbolImageRotationAngle: CGFloat? = nil,
    contentLabelText: String? = nil,
    descriptionLabelText: String? = nil,
    selectable: Bool? = nil,
    disclosable: Bool? = nil
  ) {
    self.symbolImageName = symbolImageName
    self.symbolImageRotationAngle = symbolImageRotationAngle
    self.contentLabelText = contentLabelText
    self.descriptionLabelText = descriptionLabelText
    self.isSelectable = selectable
    self.isDisclosable = disclosable
  }
}
