//
//  Daemon.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 18.02.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import Foundation

protocol Daemon {
  func startObservations()
  func stopObservations()
}
