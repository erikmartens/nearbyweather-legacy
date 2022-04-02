//
//  WeatherMapAnnotationData.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 10.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import Foundation

final class WeatherMapAnnotationData: MapAnnotationData {
  
  var annotationViewReuseIdentifier: String
  var annotationItems: [BaseAnnotationViewModelProtocol]
  
  init(
    annotationViewReuseIdentifier: String,
    annotationItems: [BaseAnnotationViewModelProtocol]
  ) {
    self.annotationViewReuseIdentifier = annotationViewReuseIdentifier
    self.annotationItems = annotationItems
  }
}
