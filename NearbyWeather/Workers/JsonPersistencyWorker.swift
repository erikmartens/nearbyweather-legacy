//
//  DataStorageService.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 08.01.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import Foundation

protocol DataStorageProtocol {
  associatedtype StorageEntity: DataStorageProtocol
  
  static func storeData()
  static func loadData() -> StorageEntity?
}

final class JsonPersistencyWorker {
  
  private static let fileExtension = "json"
  
  // MARK: - Public Functions
  
  static func storeJson<T: Encodable>(for codable: T, inFileWithName fileName: String, toStorageLocation location: FileManager.StorageLocationType) {
    guard let destinationDirectoryURL = try? FileManager.default.directoryUrl(for: location) else {
      printDebugMessage(domain: String(describing: self),
                        message: "Could not construct directory url.")
      return
    }
    
    let filePathUrl = destinationDirectoryURL.appendingPathComponent(fileName).appendingPathExtension(Self.fileExtension)
    
    do {
      try FileManager.default.createBaseDirectoryIfNeeded(for: destinationDirectoryURL.path)
      let data = try JSONEncoder().encode(codable)
      try data.write(to: filePathUrl)
    } catch let error {
      printDebugMessage(domain: String(describing: self),
                        message: "Error while writing data to \(filePathUrl.path). Error-Description: \(error.localizedDescription)")
    }
  }
  
  static func retrieveJsonFromFile<T: Decodable>(with fileName: String, andDecodeAsType type: T.Type, fromStorageLocation location: FileManager.StorageLocationType) -> T? {
    guard let fileDirectoryURL = try? FileManager.default.directoryUrl(for: location, fileName: fileName, fileExtension: JsonPersistencyWorker.fileExtension) else {
      printDebugMessage(domain: String(describing: self),
                        message: "Could not construct directory url.")
      return nil
    }
    let fileUrl = fileDirectoryURL.appendingPathComponent(fileName).appendingPathExtension(Self.fileExtension)
    
    if !FileManager.default.fileExists(atPath: fileUrl.path) {
      printDebugMessage(domain: String(describing: self),
                        message: "File at path \(fileUrl.path) does not exist!")
      return nil
    }
    do {
      let data = try Data(contentsOf: fileUrl)
      let model = try JSONDecoder().decode(type, from: data)
      return model
    } catch let error {
      printDebugMessage(domain: String(describing: self),
                        message: "DataStorageService: Error while retrieving data from \(fileUrl.path). Error-Description: \(error.localizedDescription)")
      return nil
    }
  }
}
