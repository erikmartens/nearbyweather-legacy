//
//  SettingsPreferencesItemsSubSection1.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 09.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import Foundation

final class SettingsPreferencesItemsSubSection1: BaseTableViewSectionData {
  
  init(sectionItems: [BaseCellViewModelProtocol]) {
    super.init(
      sectionHeaderTitle: nil,
      sectionFooterTitle: nil,
      sectionItems: sectionItems
    )
  }
  
  required init(
    sectionHeaderTitle: String? = nil,
    sectionFooterTitle: String? = nil,
    sectionItems: [BaseCellViewModelProtocol]
  ) {
    super.init(
      sectionHeaderTitle: sectionHeaderTitle,
      sectionFooterTitle: sectionFooterTitle,
      sectionItems: sectionItems
    )
  }
}
