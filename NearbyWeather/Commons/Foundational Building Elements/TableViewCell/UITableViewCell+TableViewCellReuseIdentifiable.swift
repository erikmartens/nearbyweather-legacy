//
//  UITableViewCell+TableViewCellReuseIdentifiable.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit.UITableViewCell

protocol TableViewCellReuseIdentifiable {
  static var reuseIdentifier: String { get }
}

extension TableViewCellReuseIdentifiable {
  static var reuseIdentifier: String {
    String(describing: self)
  }
}

extension UITableViewCell: TableViewCellReuseIdentifiable {}
