//
//  FileManager+DirectoryUrl.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 28.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

extension FileManager {
  
  enum StorageLocationType {
    case bundle
    case documents
    case applicationSupport
  }
  
  class func directoryURL(for location: StorageLocationType, fileName: String? = nil, fileExtension: String? = nil) -> URL? {
    switch location {
    case .bundle:
      return Bundle.main.bundleURL
    case .documents:
      return  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    case .applicationSupport:
      return  FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
    }
  }
}
