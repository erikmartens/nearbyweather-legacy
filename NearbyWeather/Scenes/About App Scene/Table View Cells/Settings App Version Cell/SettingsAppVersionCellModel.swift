//
//  SettingsAppVersionCellModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import UIKit

struct SettingsAppVersionCellModel {
  let appIconImage: UIImage?
  let appNameTitle: String?
  let appVersionTitle: String?
  
  init(
    appIconImage: UIImage? = nil,
    appNameTitle: String? = nil,
    appVersionTitle: String? = nil
  ) {
    self.appIconImage = appIconImage
    self.appNameTitle = appNameTitle
    self.appVersionTitle = appVersionTitle
  }
}
