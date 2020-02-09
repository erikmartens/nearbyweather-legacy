//
//  MKMapType+AllCases.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 09.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import MapKit

extension MKMapType {
  
  static var supportedCases: [MKMapType] {
    [.standard, .satellite, .hybrid]
  }
  
  var title: String {
    switch self {
      
    case .standard:
      return R.string.localizable.map_type_standard()
    case .satellite:
      return R.string.localizable.map_type_satellite()
    case .hybrid:
      return R.string.localizable.map_type_hybrid()
    default:
      return Constants.Messages.kNotSet
    }
  }
}
