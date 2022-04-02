//
//  BaseCellViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

protocol BaseCellViewModel: NSObject, BaseCellViewModelProtocol {
  associatedtype Dependencies
  init(dependencies: Dependencies)
  func observeDataSource()
  func observeUserTapEvents()
}

/// functions are optional
extension BaseCellViewModel {
  func observeDataSource() {}
  func observeUserTapEvents() {}
}
