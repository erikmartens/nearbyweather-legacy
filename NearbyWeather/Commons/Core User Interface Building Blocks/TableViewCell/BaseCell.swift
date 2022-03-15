//
//  BaseCell.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

protocol BaseCell: BaseCellProtocol {
  associatedtype CellViewModel: BaseCellViewModel
  var cellViewModel: CellViewModel? { get set }
  func bindContentFromViewModel(_ cellViewModel: CellViewModel)
  func bindUserInputToViewModel(_ cellViewModel: CellViewModel)
}

/// functions are optional
extension BaseCell {
  func bindContentFromViewModel(_ cellViewModel: CellViewModel) {}
  func bindUserInputToViewModel(_ cellViewModel: CellViewModel) {}
}
