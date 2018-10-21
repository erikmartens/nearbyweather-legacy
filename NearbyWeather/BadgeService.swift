//
//  BadgeService.swift
//  NearbyWeather
//
//  Created by Lukas Prokein on 20/10/2018.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import UIKit

final class BadgeService {
    
    // MARK: - Types
    
    private enum TemperatureSign {
        case plus
        case minus
    }
    
    // MARK: - Properties

    public static var shared: BadgeService!
    
    // MARK: - Methods
    
    public var areBadgesEnabled: Bool {
        return UserDefaults.standard.bool(forKey: kShowTempOnIconKey) && PermissionsManager.shared.areNotificationsApproved
    }
    
    public static func instantiateSharedInstance() {
        shared = BadgeService()
    }
    
    public func updateBadge() {
        guard UserDefaults.standard.bool(forKey: kShowTempOnIconKey) else { return }
        if #available(iOS 10, *) {
            PermissionsManager.shared.areNotificationsApproved { [weak self] areApproved in
                self?.performBadgeUpdate()
            }
        } else if PermissionsManager.shared.areNotificationsApproved {
            performBadgeUpdate()
        }
    }
    
    // MARK: - Helpers
    
    private func performBadgeUpdate() {
        if let weatherData = WeatherDataManager.shared.preferredBookmarkData {
            let temperatureUnit = PreferencesManager.shared.temperatureUnit
            let temperatureKelvin = weatherData.atmosphericInformation.temperatureKelvin
            let temperature = ConversionService.temperatureIntValue(forTemperatureUnit: temperatureUnit, fromRawTemperature: temperatureKelvin)
            if let temperature = temperature {
                let lastTemperature = UIApplication.shared.applicationIconBadgeNumber
                UIApplication.shared.applicationIconBadgeNumber = temperature
                if lastTemperature < 0 && temperature > 0 {
                    sendTemperatureSignChangeNotification(sign: .plus)
                } else if lastTemperature > 0 && temperature < 0 {
                    sendTemperatureSignChangeNotification(sign: .minus)
                }
            }
        } else {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    
    private func sendTemperatureSignChangeNotification(sign: TemperatureSign) {
        print("TODO: - Send change notification")
    }
}
