//
//  AddBookmarkSearchResultsSection.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 12.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import Foundation

final class AddBookmarkSearchResultsSection: BaseTableViewSectionData {
  
  init(sectionItems: [BaseCellViewModelProtocol]) {
    super.init(
      sectionHeaderTitle: nil,
      sectionFooterTitle: nil,
      sectionCellsIdentifier: SettingsDualLabelSubtitleCell.reuseIdentifier, // section only uses one type of cell
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
