//
//  BadgeService.swift
//  NearbyWeather
//
//  Created by Lukas Prokein on 20/10/2018.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import UIKit

final class BadgeService {
    
    // MARK: - Properties

    public static var shared: BadgeService!
    
    // MARK: - Methods
    
    public static func instantiateSharedInstance() {
        shared = BadgeService()
    }
    
    public var areBadgesEnabled: Bool {
        return UserDefaults.standard.bool(forKey: kShowTempOnIconKey) && PermissionsManager.shared.areBadgesApproved
    }
    
    public func updateBadge() {
        if areBadgesEnabled, let weatherData = WeatherDataManager.shared.preferredBookmarkData {
            let temperatureUnit = PreferencesManager.shared.temperatureUnit
            let temperatureKelvin = weatherData.atmosphericInformation.temperatureKelvin
            let temperature = ConversionService.temperatureIntValue(forTemperatureUnit: temperatureUnit, fromRawTemperature: temperatureKelvin)
            if let temperature = temperature {
                print("TEMP = \(temperature)")
                UIApplication.shared.applicationIconBadgeNumber = temperature
            }
        } else {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
}
