//
//  BaseCell.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

protocol BaseCell: BaseCellProtocol, ReuseIdentifiable {
  associatedtype BaseCellViewModel: BaseCellViewModelProtocol
  var cellViewModel: BaseCellViewModel? { get set }
  func bindInputFromViewModel(_ cellViewModel: BaseCellViewModel)
  func bindOutputToViewModel(_ cellViewModel: BaseCellViewModel)
}
