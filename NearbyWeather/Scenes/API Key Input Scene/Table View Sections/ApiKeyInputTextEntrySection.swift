//
//  ApiKeyInputTextEntrySection.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import Foundation

final class ApiKeyInputTextEntrySection: BaseTableViewSectionData {
  
  init(sectionItems: [BaseCellViewModelProtocol]) {
    super.init(
      sectionHeaderTitle: R.string.localizable.enter_api_key(),
      sectionFooterTitle: R.string.localizable.api_key_length_description(),
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
