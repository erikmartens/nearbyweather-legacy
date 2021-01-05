//
//  UITableView+RegisterCells.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import UIKit.UITableView
import UIKit.UITableViewCell

extension UITableView {
  
  func registerCells(_ cells: [UITableViewCell.Type]) {
    cells.forEach { registerCell($0) }
  }
  
  func registerCell(_ cell: UITableViewCell.Type) {
    register(cell, forCellReuseIdentifier: cell.reuseIdentifier)
  }
}
