//
//  BadgeService.swift
//  NearbyWeather
//
//  Created by Lukas Prokein on 20/10/2018.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import UserNotifications

final class BadgeService {
    
    // MARK: - Types
    
    private enum TemperatureSign {
        case plus
        case minus
    }
    
    private struct TemperatureSignNotificationBundle {
        let sign: TemperatureSign
        let city: String
    }
    
    // MARK: - Properties

    public static var shared: BadgeService!
    
    // MARK: - Methods
    
    public var areBadgesEnabled: Bool {
        return UserDefaults.standard.bool(forKey: kShowTempOnIconKey) && PermissionsManager.shared.areNotificationsApproved
    }
    
    public static func instantiateSharedInstance() {
        shared = BadgeService()
        
        if UserDefaults.standard.bool(forKey: kShowTempOnIconKey) {
            shared.setBackgroundFetch(enabled: true)
        }
    }
    
    public func setBadgeService(enabled: Bool) {
        if enabled {
            UserDefaults.standard.set(true, forKey: kShowTempOnIconKey)
        } else {
            UserDefaults.standard.set(false, forKey: kShowTempOnIconKey)
        }
        BadgeService.shared.updateBadge(withCompletionHandler: nil)
    }
    
    public func updateBadge(withCompletionHandler completionHandler: (() -> ())?) {
        guard UserDefaults.standard.bool(forKey: kShowTempOnIconKey) else {
            clearAppIcon()
            completionHandler?()
            return
        }
        if #available(iOS 10, *) {
            PermissionsManager.shared.areNotificationsApproved { [weak self] areApproved in
                self?.performBadgeUpdate()
                completionHandler?()
            }
        } else if PermissionsManager.shared.areNotificationsApproved {
            performBadgeUpdate()
            completionHandler?()
        }
    }
    
    public func performBackgroundBadgeUpdate(withCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        WeatherDataManager.shared.updateBookmarks { result in
            switch result {
            case .success:
                completionHandler(.newData)
            case .failure:
                completionHandler(.failed)
            }
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
                    sendTemperatureSignChangeNotification(bundle: TemperatureSignNotificationBundle(sign: .plus, city: weatherData.cityName))
                } else if lastTemperature > 0 && temperature < 0 {
                    sendTemperatureSignChangeNotification(bundle: TemperatureSignNotificationBundle(sign: .minus, city: weatherData.cityName))
                }
            }
        } else {
            clearAppIcon()
        }
    }
    
    private func clearAppIcon() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    private func sendTemperatureSignChangeNotification(bundle: TemperatureSignNotificationBundle) {
        if #available(iOS 10, *) {
            sendNewAPITemperatureSignChangeNotification(bundle: bundle)
        } else {
            sendOldAPITemperatureSignChangeNotification(bundle: bundle)
        }
    }
    
    private func sendOldAPITemperatureSignChangeNotification(bundle: TemperatureSignNotificationBundle) {
        let localNotification = UILocalNotification()
        localNotification.fireDate = Date(timeIntervalSinceNow: 2.0)
        localNotification.alertTitle = R.string.localizable.app_icon_temperature_sing_updated()
        switch bundle.sign {
        case .plus:
            localNotification.alertBody = R.string.localizable.temperature_above_zero(bundle.city)
        case .minus:
            localNotification.alertBody = R.string.localizable.temperature_below_zero(bundle.city)
        }
        localNotification.timeZone = TimeZone.current
        
        UIApplication.shared.scheduleLocalNotification(localNotification)
    }
    
    private func sendNewAPITemperatureSignChangeNotification(bundle: TemperatureSignNotificationBundle) {
        guard #available(iOS 10.0, *) else {
            sendOldAPITemperatureSignChangeNotification(bundle: bundle)
            return
        }
        let content = UNMutableNotificationContent()
        content.title = R.string.localizable.app_icon_temperature_sing_updated()
        switch bundle.sign {
        case .plus:
            content.body = R.string.localizable.temperature_above_zero(bundle.city)
        case .minus:
            content.body = R.string.localizable.temperature_below_zero(bundle.city)
        }
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2.0, repeats: false)
        let request = UNNotificationRequest(identifier: "TemperatureSignNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    private func setBackgroundFetch(enabled: Bool) {
        if enabled {
            UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        } else {
            UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalNever)
        }
    }
}
