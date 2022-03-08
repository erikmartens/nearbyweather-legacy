//
//  BaseTableViewSectionData.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 06.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import Foundation

class BaseTableViewSectionData: TableViewSectionDataProtocol {
  
  var sectionHeaderTitle: String?
  var sectionFooterTitle: String?
  let sectionCellsIdentifier: String?
  let sectionCellsIdentifiers: [String]?
  let sectionItems: [BaseCellViewModelProtocol]
  
  required init(
    sectionHeaderTitle: String? = nil,
    sectionFooterTitle: String? = nil,
    sectionCellsIdentifier: String?,
    sectionCellsIdentifiers: [String]?,
    sectionItems: [BaseCellViewModelProtocol]
  ) {
    self.sectionHeaderTitle = sectionHeaderTitle
    self.sectionFooterTitle = sectionFooterTitle
    self.sectionCellsIdentifier = sectionCellsIdentifier
    self.sectionCellsIdentifiers = sectionCellsIdentifiers
    self.sectionItems = sectionItems
  }
}
