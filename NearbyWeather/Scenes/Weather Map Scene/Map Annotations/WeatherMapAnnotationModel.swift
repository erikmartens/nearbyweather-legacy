//
//  WeatherMapAnnotationModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 10.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import MapKit

struct WeatherMapAnnotationModel {
  let title: String?
  let subtitle: String?
  let isDayTime: Bool?
  let borderColor: UIColor?
  let backgroundColor: UIColor?
  
  init(
    title: String? = nil,
    subtitle: String? = nil,
    isDayTime: Bool? = false,
    borderColor: UIColor? = nil,
    backgroundColor: UIColor? = nil
  ) {
    self.title = title
    self.subtitle = subtitle
    self.isDayTime = isDayTime
    self.borderColor = borderColor
    self.backgroundColor = backgroundColor
  }
}
