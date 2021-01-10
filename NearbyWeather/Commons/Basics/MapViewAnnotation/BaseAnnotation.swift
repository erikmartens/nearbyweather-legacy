//
//  BaseAnnotation.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 10.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import Foundation

typealias BaseAnnotationViewModel = BaseAnnotation

protocol BaseAnnotation: NSObject, BaseAnnotationProtocol {
  associatedtype Dependencies
  init(dependencies: Dependencies)
  func observeDataSource()
  func observeUserTapEvents()
}

/// functions are optional
extension BaseAnnotation {
  func observeDataSource() {}
  func observeUserTapEvents() {}
}
