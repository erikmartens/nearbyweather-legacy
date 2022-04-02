//
//  InstallVersionModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 28.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import Foundation

struct InstallVersionModel: Codable, Equatable {
  var major: Int
  var minor: Int
  var patch: Int
}

extension String {
  
  var toInstallVersion: InstallVersionModel? {
    guard range(of: "^[0-9]*.[0-9]*.[0-9]*$", options: .regularExpression) != nil else {
      return nil
    }
    let components = components(separatedBy: ".")
    guard components.count == 3,
          let majorString = components[safe: 0],
          let major = Int(majorString),
          let minorString = components[safe: 1],
          let minor = Int(minorString),
          let patchString = components[safe: 2],
          let patch = Int(patchString) else {
      return nil
    }
    return InstallVersionModel(major: major, minor: minor, patch: patch)
  }
}
