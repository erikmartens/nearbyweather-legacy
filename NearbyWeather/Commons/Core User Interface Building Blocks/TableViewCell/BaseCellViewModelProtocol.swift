//
//  BaseCellViewModelProtocol.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 02.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import RxFlow

protocol BaseCellViewModelProtocol {
  var associatedCellReuseIdentifier: String { get }
  var onSelectedRoutingIntent: Step? { get }
  var canEditRow: Bool { get }
  var canMoveRow: Bool { get }
}

extension BaseCellViewModelProtocol {
  var onSelectedRoutingIntent: Step? { nil }
  var canEditRow: Bool { false }
  var canMoveRow: Bool { false }
}
