//
//  Constants+Keys.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 28.01.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

extension Constants {
  enum Keys {}
}

extension Constants.Keys {
  
  enum UserDefaults {
    static let kNearbyWeatherApiKeyKey = "nearby_weather.openWeatherMapApiKey"
    static let kIsInitialLaunch = "nearby_weather.isInitialLaunch"
    static let kRefreshOnAppStartKey = "de.erikmaximilianmartens.nearbyWeather.refreshOnAppStart"
    static let kWeatherDataLastRefreshDateKey = "de.erikmaximilianmartens.nearbyWeather.weatherDataService.lastUpdateDate"
    static let kIsTemperatureOnAppIconEnabledKey = "de.erikmaximilianmartens.nearbyWeather.isTemperatureOnAppIconEnabled"
  }
}

extension Constants.Keys {
  
  enum NotificationCenter {
    static let kWeatherServiceDidUpdate = "de.erikmaximilianmartens.nearbyWeather.weatherServiceDidUpdate"
    static let kLocationAuthorizationUpdated = "de.erikmaximilianmartens.nearbyWeather.locationAuthorizationUpdated"
    static let kNetworkReachabilityChanged = "de.erikmaximilianmartens.nearbyWeather.networkReachabilityChanged"
    static let kSortingOrientationPreferenceChanged = "de.erikmaximilianmartens.nearbyWeather.sortingOrientationPreferenceChanged"
  }
}
