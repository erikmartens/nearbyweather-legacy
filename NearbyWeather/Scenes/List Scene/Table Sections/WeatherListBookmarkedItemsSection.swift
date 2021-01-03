//
//  WeatherListBookmarkedItemsSection.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import Foundation

final class WeatherListBookmarkedItemsSection: TableViewSectionData {
  
  var sectionHeaderTitle: String?
  var sectionFooterTitle: String?
  let sectionCellsIdentifier: String
  let sectionItems: [BaseCellViewModelProtocol]
  
  init(
    sectionHeaderTitle: String? = nil,
    sectionFooterTitle: String? = nil,
    sectionCellsIdentifier: String,
    sectionItems: [BaseCellViewModelProtocol]
  ) {
    self.sectionHeaderTitle = sectionHeaderTitle
    self.sectionFooterTitle = sectionFooterTitle
    self.sectionCellsIdentifier = sectionCellsIdentifier
    self.sectionItems = sectionItems
  }
}
