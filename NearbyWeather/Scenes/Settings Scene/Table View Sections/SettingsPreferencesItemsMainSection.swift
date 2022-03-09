//
//  SettingsPreferencesItemsMainSection.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 06.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import Foundation

final class SettingsPreferencesItemsMainSection: BaseTableViewSectionData {
  
  init(sectionItems: [BaseCellViewModelProtocol]) {
    super.init(
      sectionHeaderTitle: R.string.localizable.preferences(),
      sectionFooterTitle: nil,
      sectionCellsIdentifier: nil,
      sectionCellsIdentifiers: [
        SettingsImagedSingleLabelToggleCell.reuseIdentifier
      ],
      sectionItems: sectionItems
    )
  }
  
  required init(
    sectionHeaderTitle: String? = nil,
    sectionFooterTitle: String? = nil,
    sectionCellsIdentifier: String?,
    sectionCellsIdentifiers: [String]?,
    sectionItems: [BaseCellViewModelProtocol]
  ) {
    super.init(
      sectionHeaderTitle: sectionHeaderTitle,
      sectionFooterTitle: sectionFooterTitle,
      sectionCellsIdentifier: sectionCellsIdentifier,
      sectionCellsIdentifiers: sectionCellsIdentifiers,
      sectionItems: sectionItems
    )
  }
}
