//
//  BaseCellProtocol.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 02.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import UIKit

protocol BaseCellProtocol: UITableViewCell {
  func configure(with cellViewModel: BaseCellViewModelProtocol?)
}
