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
  
  enum KeyValueBindings {
    static let kImage = "image"
    static let kChecked = "checked"
  }
  
  // used for migration
  enum UserDefaults {
    static let kNearbyWeatherApiKeyKey = "nearby_weather.openWeatherMapApiKey"
    static let kRefreshOnAppStartKey = "de.erikmaximilianmartens.nearbyWeather.refreshOnAppStart"
    static let kIsTemperatureOnAppIconEnabledKey = "de.erikmaximilianmartens.nearbyWeather.isTemperatureOnAppIconEnabled"
  }
  
  enum BackgroundTaskIdentifiers {
    static let kRefreshTempOnAppIconBadge = "de.erikmaximilianmartens.nearbyweather.temperature_as_app_icon_bagde_background_fetch"
  }
  
  enum NotificationIdentifiers {
    static let kAppIconTemeperatureNotification = "de.erikmaximilianmartens.nearbyweather.temeperature_polarity_changed_notification"
  }
  
  // used for migration
  enum Storage {
    static let kWeatherDataManagerStoredContentsFileName = "WeatherDataManagerStoredContents"
    static let kPreferencesManagerStoredContentsFileName = "PreferencesManagerStoredContents"
  }
}
