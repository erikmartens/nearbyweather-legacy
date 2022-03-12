//
//  BaseTableViewSelectionDelegate.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import Foundation

protocol BaseTableViewSelectionDelegate: AnyObject {
  func didSelectRow(at indexPath: IndexPath)
}
