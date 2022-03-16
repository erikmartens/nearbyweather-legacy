//
//  ThirdPartyLibraryDTO.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 29.10.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import Foundation

struct ThirdPartyLibrariesWrapperDTO: Codable {
  var elements: [ThirdPartyLibraryDTO]
}

struct ThirdPartyLibraryDTO: Codable, Equatable {
  var name: String
  var urlString: String
}
