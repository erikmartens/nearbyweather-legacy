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
  
  var sectionCellsIdentifier: String { get }
  var sectionItems: [BaseCellViewModelProtocol] { get }
  
  var sectionCellsCount: Int { get }
  
  init(
    sectionHeaderTitle: String?,
    sectionFooterTitle: String?,
    sectionCellsIdentifier: String,
    sectionItems: [BaseCellViewModelProtocol]
  )
}

extension TableViewSectionDataProtocol {
  var sectionCellsCount: Int { sectionItems.count }
}
