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
      .andThen(
        createGetNotificationAuthorizationStatusSingle()
          .flatMapCompletable { [unowned self] authorizationStatus in
            if authorizationStatus.authorizationStatusIsSufficient {
              return Completable.create {
                $0(.completed)
                return Disposables.create()
              }
            }
            return requestNotificationDeliveryAuthorization()
          }
      )
      .andThen(createChangeTemperatureOnAppIconNotificationProvisioningCompletable())
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
      .replaceNilWith(ShowTemperatureOnAppIconOption(value: .yes)) // default value
  }
  
  // MARK: - Notification Provisioning
  
  func createChangeTemperatureOnAppIconNotificationProvisioningCompletable() -> Completable {
    createGetNotificationAuthorizationStatusSingle()
      .do(onSuccess: { [unowned self] authorizationStatus in
        if !authorizationStatus.authorizationStatusIsSufficient {
          clearAppIconBadge()
        }
      })
      .flatMapCompletable { [unowned self] authorizationStatus in
        return setBackgroundFetchEnabled(authorizationStatus.authorizationStatusIsSufficient)
      }
  }
  
  func createPerformTemperatureOnBadgeUpdateCompletable() -> Completable {
    struct ResultType {
      let stationName: String
      let newTemperature: Int
      let temperatureUnitOption: TemperatureUnitOption
    }
    
    return dependencies.weatherStationService
      .createGetPreferredBookmarkObservable()
      .do(onNext: { [unowned self] preferredBookmarkOption in
        if preferredBookmarkOption?.value.stationIdentifier == nil {
          clearAppIconBadge()
        }
      })
        .filterNil()
        .filter { $0.value.stationIdentifier != nil }
        .flatMapLatest { [unowned self] preferredBookmarkOption in
          Observable
            .combineLatest(
              dependencies.weatherInformationService.createGetNearbyWeatherInformationObservable(for: "\(preferredBookmarkOption.value.stationIdentifier!)"),
              dependencies.preferencesService.createGetTemperatureUnitOptionObservable(),
              resultSelector: { weatherInformationDto, temperatureUnitOption -> ResultType? in
                guard let temperatureKelvin = weatherInformationDto.entity.atmosphericInformation.temperatureKelvin,
                      let temperatureIntValue = MeteorologyInformationConversionWorker.temperatureIntValue(
                        forTemperatureUnit: temperatureUnitOption,
                        fromRawTemperature: temperatureKelvin
                      )
                else {
                  return nil
                }
                
                return ResultType(
                  stationName: weatherInformationDto.entity.stationName,
                  newTemperature: temperatureIntValue,
                  temperatureUnitOption: temperatureUnitOption
                )
              })
        }
        .filterNil()
        .take(1)
        .asSingle()
        .flatMapCompletable { [unowned self] result in
          let previousTemperatureValue = UIApplication.shared.applicationIconBadgeNumber // TODO: how does this even work? This would never be negative
          UIApplication.shared.applicationIconBadgeNumber = abs(result.newTemperature)
          
          if previousTemperatureValue < 0 && result.newTemperature > 0 {
            return createSendTemperaturePolarityChangedNotificationCompletable(inputContent: TemperaturePolarityChangedNotificationContent(
              sign: .positive,
              unit: result.temperatureUnitOption,
              temperature: result.newTemperature,
              cityName: result.stationName
            ))
          } else if previousTemperatureValue > 0 && result.newTemperature < 0 {
            return createSendTemperaturePolarityChangedNotificationCompletable(inputContent: TemperaturePolarityChangedNotificationContent(
              sign: .negative,
              unit: result.temperatureUnitOption,
              temperature: result.newTemperature,
              cityName: result.stationName
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
  func createChangeTemperatureOnAppIconNotificationProvisioningCompletable() -> Completable
  func createPerformTemperatureOnBadgeUpdateCompletable() -> Completable
}

extension NotificationService: AppIconNotificationProvisioning {}

// MARK: - Helpers

private extension NotificationService {
  
  func clearAppIconBadge() {
    UIApplication.shared.applicationIconBadgeNumber = 0
  }
  
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
  
  func setBackgroundFetchEnabled(_ enabled: Bool) -> Completable {
    Completable
      .create { handler in
        UIApplication.shared.setMinimumBackgroundFetchInterval(enabled ? UIApplication.backgroundFetchIntervalMinimum : UIApplication.backgroundFetchIntervalNever)
        handler(.completed)
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
