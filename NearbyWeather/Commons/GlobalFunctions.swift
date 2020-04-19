//
//  GlobalFunctions.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 29.01.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation
import Firebase

func printDebugMessage(domain: String, message: String) {
  guard !BuildEnvironment.isReleaseEvironment() else {
    return
  }
  debugPrint(
    "💥"
      .append(contentsOf: domain, delimiter: .space)
      .append(contentsOf: message, delimiter: .custom(string: " : "))
  )
}

func reportNonFatalError(_ error: NSError) {
  Crashlytics.crashlytics().record(error: error)
}

func reportCustomNonFatalError(for domain: String, message: String) {
  let error = NSError(
    domain: domain,
    code: -1,
    userInfo: ["message": message]
  )
  Crashlytics.crashlytics().record(error: error)
}
