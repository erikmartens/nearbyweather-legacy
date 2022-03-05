//
//  WeatherStationCurrentInformationMapCellMapAnnotationData.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 16.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

final class WeatherStationMeteorologyDetailsMapCellMapAnnotationData: MapAnnotationData { // swiftlint:disable:this type_name
  
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
