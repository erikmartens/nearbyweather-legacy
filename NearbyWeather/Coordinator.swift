//
//  File.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 01.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit

protocol Step {}

protocol Coordinator {
  var rootViewController: UIViewController { get }
  func navigateToStep(_ step: Step) -> Coordinator?
}
