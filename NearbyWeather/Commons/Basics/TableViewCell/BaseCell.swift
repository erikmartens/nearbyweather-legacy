//
//  BaseCell.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

protocol BaseCell: BaseCellProtocol {
  associatedtype CellViewModel: BaseCellViewModelProtocol
  var cellViewModel: CellViewModel? { get set }
  func bindInputFromViewModel(_ cellViewModel: CellViewModel)
  func bindOutputToViewModel(_ cellViewModel: CellViewModel)
}

/// functions are optional
extension BaseCell {
  func bindInputFromViewModel(_ cellViewModel: CellViewModel) {}
  func bindOutputToViewModel(_ cellViewModel: CellViewModel) {}
}
