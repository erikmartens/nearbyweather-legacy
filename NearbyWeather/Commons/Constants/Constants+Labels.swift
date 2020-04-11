//
//  Constants+Labels.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 30.01.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

extension Constants {
  enum Labels {}
}

extension Constants.Labels {
  
  enum DispatchQueues {
    static let kOpenWeatherMapCityServiceBackgroundQueue = "de.erikmaximilianmartens.nearbyWeather.openWeatherMapCityService"
    static let kFetchWeatherDataBackgroundQueue = "de.erikmaximilianmartens.nearbyWeather.fetchWeatherDataQueue"
    static let kWeatherServiceBackgroundQueue = "de.erikmaximilianmartens.nearbyWeather.weatherDataManagerBackgroundQueue"
    static let kPreferencesManagerBackgroundQueue = "de.erikmaximilianmartens.nearbyWeather.preferencesManagerBackgroundQueue"
    static let kWeatherFetchQueue = "de.erikmaximilianmartens.nearbyWeather.weatherFetchQueue"
  }
}
