//
//  DataStorageProtocol.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 16.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

protocol DataStorageProtocol {
  associatedtype StorageEntity: DataStorageProtocol
  
  static func storeData()
  static func loadData() -> StorageEntity?
}
