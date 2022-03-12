//
//  TableSectionDataSource.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 02.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import Foundation

protocol TableViewSectionDataProtocol {
  var sectionHeaderTitle: String? { get set }
  var sectionFooterTitle: String? { get set }
  
  /// a cell identifier must be supplied one way or the other - use sectionCellsIdentifiers when using multiple cell types within the same section
  var sectionCellsIdentifier: String? { get }
  var sectionCellsIdentifiers: [String]? { get }
  
  var sectionItems: [BaseCellViewModelProtocol] { get }
  
  var sectionCellsCount: Int { get }
  
  init(
    sectionHeaderTitle: String?,
    sectionFooterTitle: String?,
    sectionCellsIdentifier: String?,
    sectionCellsIdentifiers: [String]?,
    sectionItems: [BaseCellViewModelProtocol]
  )
}

extension TableViewSectionDataProtocol {
  var sectionCellsCount: Int { sectionItems.count }
}
