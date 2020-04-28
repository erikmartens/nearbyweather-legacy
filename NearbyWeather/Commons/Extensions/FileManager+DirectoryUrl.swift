//
//  FileManager+DirectoryUrl.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 28.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

extension FileManager {
  
  enum FileManagerError: String, Error {
    case directoryUrlDeterminationError = "Could not determine the specified directory within the SearchPathDirectory"
  }
  
  enum StorageLocationType {
    case bundle
    case documents
    case applicationSupport
  }
  
  class func directoryUrl(for location: StorageLocationType, fileName: String? = nil, fileExtension: String? = nil) throws -> URL {
    var url: URL?
    
    switch location {
    case .bundle:
      url = Bundle.main.bundleURL
    case .documents:
      url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    case .applicationSupport:
      url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
    }
    
    guard let result = url else {
      throw FileManager.FileManagerError.directoryUrlDeterminationError
    }
    return result
  }
}
