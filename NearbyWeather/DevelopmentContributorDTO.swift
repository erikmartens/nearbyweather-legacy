//
//  DevelopmentContributorDTO.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 29.10.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import Foundation

struct DevelopmentContributorArrayWrapper: Codable {
  var elements: [DevelopmentContributorDTO]
}

struct DevelopmentContributorDTO: Codable {
  var firstName: String
  var lastName: String
  var contributionDescription: String?
  var urlString: String
}
