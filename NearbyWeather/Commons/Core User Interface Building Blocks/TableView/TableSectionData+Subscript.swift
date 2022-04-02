//
//  TableSectionData+Subscript.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa

extension BehaviorRelay where Element == [TableViewSectionDataProtocol]? {
  subscript (indexPath: IndexPath) -> BaseCellViewModelProtocol? {
    return value?[safe: indexPath.section]?.sectionItems[safe: indexPath.row]
  }
}
