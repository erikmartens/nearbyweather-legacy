//
//  AboutAppLibrariesItemsSection.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import Foundation

final class AboutAppLibrariesItemsSection: BaseTableViewSectionData {
  
  init(sectionItems: [BaseCellViewModelProtocol]) {
    super.init(
      sectionHeaderTitle: R.string.localizable.libraries(),
      sectionFooterTitle: nil,
      sectionCellsIdentifier: SettingsSingleLabelCell.reuseIdentifier,  // section only uses one type of cell
      sectionCellsIdentifiers: nil,
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
