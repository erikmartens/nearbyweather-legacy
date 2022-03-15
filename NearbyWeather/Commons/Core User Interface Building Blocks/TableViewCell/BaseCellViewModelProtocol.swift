//
//  BaseCellViewModelProtocol.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 02.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import Foundation

protocol BaseCellViewModelProtocol {
  var canEditRow: Bool { get }
  var canMoveRow: Bool { get }
}

extension BaseCellViewModelProtocol {
  var canEditRow: Bool { false }
  var canMoveRow: Bool { false }
}
