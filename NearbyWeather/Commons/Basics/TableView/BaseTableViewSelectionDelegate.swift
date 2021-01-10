//
//  BaseTableViewSelectionDelegate.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import Foundation

protocol BaseTableViewSelectionDelegate: class {
  func didSelectRow(at indexPath: IndexPath)
}
