//
//  AboutAppContributorsItemsMainSection.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import Foundation

final class AboutAppContributorsItemsMainSection: BaseTableViewSectionData {
  
  init(sectionItems: [BaseCellViewModelProtocol]) {
    super.init(
      sectionHeaderTitle: R.string.localizable.contributors(),
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
