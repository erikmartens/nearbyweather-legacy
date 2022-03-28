//
//  SettingsBundleTransferService.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 12.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

final class SettingsBundleTransferWorker {
  
  private struct SettingsBundleIdentifier {
    static let appVersion = "app_version_identifier"
    static let appBuild = "app_build_identifier"
  }
  
  static func updateSystemSettings() {
    if let appVersion = appVersion {
      UserDefaults.standard.set(appVersion, forKey: SettingsBundleIdentifier.appVersion)
    }
    if let appBuild = appBuild {
      UserDefaults.standard.set(appBuild, forKey: SettingsBundleIdentifier.appBuild)
    }
  }
}
