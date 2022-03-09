//
//  SettingsBookmarksItemsSubSection1.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 09.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import Foundation

final class SettingsBookmarksItemsSubSection1: BaseTableViewSectionData {
  
  init(sectionItems: [BaseCellViewModelProtocol]) {
    super.init(
      sectionHeaderTitle: nil,
      sectionFooterTitle: nil,
      sectionCellsIdentifier: nil,
      sectionCellsIdentifiers: [
        SettingsImagedSingleLabelToggleCell.reuseIdentifier,
        SettingsImagedDualLabelCell.reuseIdentifier
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
