//
//  NotificationService.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 12.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import UserNotifications
import RxSwift

// MARK: - Domain-Specific Errors

extension NotificationService {
  enum DomainError: String, Error {
    var domain: String { "NotificationService" }
    
    case notificationAuthorizationRequestError = "Trying request the notification authorization, but an error occured."
    case notificationDeliveryError = "Trying to add a notifiction to UNNotificationCenter, but an error occured."
  }
}

// MARK: - Persistency Keys

private extension NotificationService {
  enum PersistencyKeys {
    case showTemperatureAsAppIconBadge
    
    var collection: String {
      switch self {
      case .showTemperatureAsAppIconBadge: return "/user_notification/ios/show_temperature_as_app_icon_badge/"
      }
    }
    
    var identifier: String {
      switch self {
      case .showTemperatureAsAppIconBadge: return "default"
      }
    }
    
    var identity: PersistencyModelIdentity {
      PersistencyModelIdentity(collection: collection, identifier: identifier)
    }
  }
}

// MARK: - Types

struct TemperatureOnAppIconBadgeInformation {
  let stationName: String
  let temperature: Int
  let temperatureUnitOption: TemperatureUnitOption
  
  init(
    stationName: String,
    temperature: Int,
    temperatureUnitOption: TemperatureUnitOption
  ) {
    self.stationName = stationName
    self.temperature = temperature
    self.temperatureUnitOption = temperatureUnitOption
  }
  
  init?(
    weatherInformationModel: WeatherInformationDTO,
    temperatureUnitOption: TemperatureUnitOption
  ) {
    guard let temperatureKelvin = weatherInformationModel.atmosphericInformation.temperatureKelvin,
          let temperature = MeteorologyInformationConversionWorker.temperatureIntValue(forTemperatureUnit: temperatureUnitOption,fromRawTemperature: temperatureKelvin) else {
      return nil
    }
    self.init(stationName: weatherInformationModel.stationName, temperature: temperature, temperatureUnitOption: temperatureUnitOption)
  }
}

private enum TemperaturePolarity {
  case positive
  case negative
  
  var stringValue: String {
    switch self {
    case .positive: return R.string.localizable.plus()
    case .negative: return R.string.localizable.minus()
    }
  }
}

private struct TemperaturePolarityChangedNotificationContent {
  let sign: TemperaturePolarity
  let unit: TemperatureUnitOption
  let temperature: Int
  let cityName: String
}

// MARK: - Dependencies

extension NotificationService {
  struct Dependencies {
    let persistencyService: PersistencyProtocol
    let weatherStationService: WeatherStationBookmarkReading
    let weatherInformationService: WeatherInformationReading
    let preferencesService: SettingsPreferencesReading
  }
}

// MARK: - Class Definition

final class NotificationService {
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  private let userNotificationCenter: UNUserNotificationCenter
  
  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
    userNotificationCenter = UNUserNotificationCenter.current()
  }
}

extension NotificationService {
  
  // MARK: - Authorization Handling
  
  func requestNotificationDeliveryAuthorization() -> Completable {
    Completable
      .create { [unowned userNotificationCenter] handler in
        userNotificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
          guard error != nil else {
            handler(.error(DomainError.notificationAuthorizationRequestError))
            return
          }
          handler(.completed)
        }
        return Disposables.create()
      }
  }
  
  func createGetNotificationSettingsSingle() -> Single<UNNotificationSettings> {
    Single
      .create { [unowned userNotificationCenter] handler in
        userNotificationCenter.getNotificationSettings { notificationSettings in
          handler(.success(notificationSettings))
        }
        return Disposables.create()
      }
  }
  
  func createGetNotificationAuthorizationStatusSingle() -> Single<UNAuthorizationStatus> {
    createGetNotificationSettingsSingle().map { $0.authorizationStatus }
  }
  
  // MARK: - Notification Preferences
  
  func createSetShowTemperatureOnAppIconOptionCompletable(_ option: ShowTemperatureOnAppIconOption) -> Completable {
    Single
      .just(option)
      .map {
        PersistencyModel<ShowTemperatureOnAppIconOption>(
          identity: PersistencyModelIdentity(
            collection: PersistencyKeys.showTemperatureAsAppIconBadge.collection,
            identifier: PersistencyKeys.showTemperatureAsAppIconBadge.identifier
          ),
          entity: $0
        )
      }
      .flatMapCompletable { [dependencies] in dependencies.persistencyService.saveResource($0, type: ShowTemperatureOnAppIconOption.self) }
  }
  
  func createGetShowTemperatureOnAppIconOptionObservable() -> Observable<ShowTemperatureOnAppIconOption> {
    dependencies
      .persistencyService
      .observeResource(
        with: PersistencyModelIdentity(
          collection: PersistencyKeys.showTemperatureAsAppIconBadge.collection,
          identifier: PersistencyKeys.showTemperatureAsAppIconBadge.identifier
        ),
        type: ShowTemperatureOnAppIconOption.self
      )
      .map { $0?.entity }
      .replaceNilWith(ShowTemperatureOnAppIconOption(value: .no)) // default value
  }
  
  // MARK: - Notification Provisioning
  
  func createPerformTemperatureOnBadgeUpdateCompletable(with information: TemperatureOnAppIconBadgeInformation) -> Completable {
    Observable
      .just(information)
      .take(1)
      .asSingle()
      .flatMapCompletable { [unowned self] information in
        let previousTemperatureValue = UIApplication.shared.applicationIconBadgeNumber // TODO: how does this even work? This would never be negative
        DispatchQueue.main.async {
          UIApplication.shared.applicationIconBadgeNumber = abs(information.temperature)
        }
        
        if previousTemperatureValue < 0 && information.temperature > 0 {
          return createSendTemperaturePolarityChangedNotificationCompletable(inputContent: TemperaturePolarityChangedNotificationContent(
            sign: .positive,
            unit: information.temperatureUnitOption,
            temperature: information.temperature,
            cityName: information.stationName
          ))
        } else if previousTemperatureValue > 0 && information.temperature < 0 {
          return createSendTemperaturePolarityChangedNotificationCompletable(inputContent: TemperaturePolarityChangedNotificationContent(
            sign: .negative,
            unit: information.temperatureUnitOption,
            temperature: information.temperature,
            cityName: information.stationName
          ))
        } else {
          return Completable.create { handler in
            handler(.completed)
            return Disposables.create()
          }
        }
      }
  }
}

// MARK: - User Location Permissions Requesting

protocol UserNotificationPermissionRequesting {
  func requestNotificationDeliveryAuthorization() -> Completable
  func createGetNotificationSettingsSingle() -> Single<UNNotificationSettings>
  func createGetNotificationAuthorizationStatusSingle() -> Single<UNAuthorizationStatus>
}

extension NotificationService: UserNotificationPermissionRequesting {}

// MARK: - Notification Preferences

protocol NotificationPreferencesPersistence: NotificationPreferencesSetting, NotificationPreferencesReading {}
extension NotificationService: NotificationPreferencesPersistence {}

protocol NotificationPreferencesSetting {
  func createSetShowTemperatureOnAppIconOptionCompletable(_ option: ShowTemperatureOnAppIconOption) -> Completable
}

extension NotificationService: NotificationPreferencesSetting {}

protocol NotificationPreferencesReading {
  func createGetShowTemperatureOnAppIconOptionObservable() -> Observable<ShowTemperatureOnAppIconOption>
}

extension NotificationService: NotificationPreferencesReading {}

// MARK: - Temperature On App Icon Notification Provisioning

protocol AppIconNotificationProvisioning {
  func createPerformTemperatureOnBadgeUpdateCompletable(with information: TemperatureOnAppIconBadgeInformation) -> Completable
}

extension NotificationService: AppIconNotificationProvisioning {}

// MARK: - Helpers

private extension NotificationService {
  
  func createSendTemperaturePolarityChangedNotificationCompletable(inputContent: TemperaturePolarityChangedNotificationContent) -> Completable {
    Completable
      .create { [unowned self] handler in
        let notificationBody = R.string.localizable.temperature_notification(
          inputContent.cityName,
          inputContent.sign.stringValue
            .append(contentsOfConvertible: inputContent.temperature, delimiter: .space)
            .append(contentsOf: inputContent.unit.value.abbreviation, delimiter: .none)
        )
        
        let content = UNMutableNotificationContent()
        
        switch inputContent.sign {
        case .positive:
          content.title = R.string.localizable.app_icon_temperature_sign_updated_above_zero()
        case .negative:
          content.title = R.string.localizable.app_icon_temperature_sign_updated_below_zero()
        }
        content.body = notificationBody
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
        let request = UNNotificationRequest(identifier: Constants.Keys.NotificationIdentifiers.kAppIconTemeperatureNotification,
                                            content: content,
                                            trigger: trigger)
        
        userNotificationCenter.add(request) { error in
          guard error == nil else {
            handler(.error(DomainError.notificationDeliveryError))
            return
          }
          handler(.completed)
        }
        return Disposables.create()
      }
  }
}

// MARK: - Helper Extensions

extension UNAuthorizationStatus {
  
  var authorizationStatusIsSufficient: Bool {
    switch self {
    case .notDetermined, .denied:
      return false
    case .authorized, .provisional, .ephemeral:
      return true
    @unknown default:
      return false
    }
  }
}
