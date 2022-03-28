//
//  BaseViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

protocol BaseViewModel: NSObject, ViewControllerLifeCycleRelay {
  associatedtype Dependencies
  init(dependencies: Dependencies)
  func observeEvents()
  func disregardEvents()
  func observeDataSource()
  func observeUserTapEvents()
}

/// functions are optional
extension BaseViewModel {
  func observeEvents() {
    observeDataSource()
    observeUserTapEvents()
  }
  
  func observeDataSource() {}
  func observeUserTapEvents() {}
}
