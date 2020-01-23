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
    
    var stringValue: String {
      switch self {
      case .plus:
        return R.string.localizable.plus()
      case .minus:
        return R.string.localizable.minus()
      }
    }
  }
  
  private struct TemperatureSignNotificationBundle {
    let sign: TemperatureSign
    let unit: TemperatureUnit
    let temperature: Int
    let cityName: String
  }
  
  // MARK: - Properties
  
  public static var shared: BadgeService!
  
  // MARK: - Methods
  
  public func isAppIconBadgeNotificationEnabled(with completionHandler: @escaping (Bool) -> ()) {
    guard UserDefaults.standard.bool(forKey: kIsTemperatureOnAppIconEnabledKey) else {
      completionHandler(false)
      return
    }
    PermissionsManager.shared.requestNotificationPermissions(with: completionHandler)
  }
  
  public static func instantiateSharedInstance() {
    shared = BadgeService()
    
    if UserDefaults.standard.bool(forKey: kIsTemperatureOnAppIconEnabledKey) {
      shared.setBackgroundFetchEnabled(true)
    }
  }
  
  public func setTemperatureOnAppIconEnabled(_ enabled: Bool) {
    UserDefaults.standard.set(enabled, forKey: kIsTemperatureOnAppIconEnabledKey)
    BadgeService.shared.updateBadge()
  }
  
  public func updateBadge() {
    guard UserDefaults.standard.bool(forKey: kIsTemperatureOnAppIconEnabledKey) else {
      clearAppIcon()
      return
    }
    PermissionsManager.shared.requestNotificationPermissions { [weak self] approved in
      guard approved else {
        self?.clearAppIcon()
        return
      }
      self?.performBadgeUpdate()
    }
  }
  
  // MARK: - Helpers
  
  private func performBadgeUpdate() {
    guard let weatherData = WeatherDataManager.shared.preferredBookmarkData else {
      clearAppIcon()
      return
    }
    
    let temperatureUnit = PreferencesManager.shared.temperatureUnit
    let temperatureKelvin = weatherData.atmosphericInformation.temperatureKelvin
    guard let temperature = ConversionService.temperatureIntValue(forTemperatureUnit: temperatureUnit, fromRawTemperature: temperatureKelvin) else { return }
    let previousTemperatureValue = UIApplication.shared.applicationIconBadgeNumber
    UIApplication.shared.applicationIconBadgeNumber = abs(temperature)
    if previousTemperatureValue < 0 && temperature > 0 {
      sendTemperatureSignChangeNotification(bundle: TemperatureSignNotificationBundle(sign: .plus, unit: temperatureUnit, temperature: temperature, cityName: weatherData.cityName))
    } else if previousTemperatureValue > 0 && temperature < 0 {
      sendTemperatureSignChangeNotification(bundle: TemperatureSignNotificationBundle(sign: .minus, unit: temperatureUnit, temperature: temperature, cityName: weatherData.cityName))
    }
  }
  
  private func clearAppIcon() {
    UIApplication.shared.applicationIconBadgeNumber = 0
  }
  
  private func sendTemperatureSignChangeNotification(bundle: TemperatureSignNotificationBundle) {
    let notificationBody = R.string.localizable.temperature_notification(bundle.cityName, "\(bundle.sign.stringValue) \(bundle.temperature)\(bundle.unit.abbreviation)")
    
    let content = UNMutableNotificationContent()
    content.title = R.string.localizable.app_icon_temperature_sign_updated()
    content.body = notificationBody
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2.0, repeats: false)
    let request = UNNotificationRequest(identifier: "TemperatureSignNotification", content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
  }
  
  private func setBackgroundFetchEnabled(_ enabled: Bool) {
    guard enabled else {
      UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalNever)
      return
    }
    UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
  }
}
