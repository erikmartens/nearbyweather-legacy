//
//  MapViewData.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 10.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import Foundation

protocol MapAnnotationData {
  
  var annotationViewReuseIdentifier: String { get }
  var annotationItems: [BaseAnnotationViewModelProtocol] { get }
  
  var annotationItemsCount: Int { get }
  
  init(
    annotationViewReuseIdentifier: String,
    annotationItems: [BaseAnnotationViewModelProtocol]
  )
}

extension MapAnnotationData {
  var annotationItemsCount: Int { annotationItems.count }
}
