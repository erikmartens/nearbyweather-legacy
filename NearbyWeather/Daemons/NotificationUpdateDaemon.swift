//
//  NotificationUpdateDaemon.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 17.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa
import RxOptional

// MARK: - Dependencies

extension NotificationUpdateDaemon {
  struct Dependencies {
    var weatherStationService: WeatherStationBookmarkReading
    var weatherInformationService: WeatherInformationReading
    var preferencesService: SettingsPreferencesReading
    var notificationService: NotificationPreferencesReading & AppIconNotificationProvisioning & UserNotificationPermissionRequesting
  }
}

// MARK: - Class Definition

final class NotificationUpdateDaemon: NSObject, Daemon {
  
  // MARK: - Assets
  
  private var disposeBag = DisposeBag()
  
  // MARK: - Subject
  
  let notificationAuthorizationStatusSubject = PublishRelay<UNAuthorizationStatus>()
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  private let notificationCenter: UNUserNotificationCenter
  
  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
    notificationCenter = UNUserNotificationCenter.current()
  }
  
  deinit {
    printDebugMessage(
      domain: String(describing: self),
      message: "was deinitialized",
      type: .info
    )
  }
  
  // MARK: - Functions
  
  func startObservations() {
    observeTemperatureOnAppIconSettingsChanges()
  }
  
  func stopObservations() {
    disposeBag = DisposeBag()
  }
}

extension NotificationUpdateDaemon {
  
  func observeTemperatureOnAppIconSettingsChanges() {
    dependencies.notificationService
      .createGetShowTemperatureOnAppIconOptionObservable()
    // check wether user wants badges on the app icon and has authorized notification
      .flatMapLatest { [unowned self] showTempOnAppIconOption -> Observable<Bool> in
        guard showTempOnAppIconOption.value == .yes else {
          return Observable.just(false)
        }
        return dependencies.notificationService
          .createGetNotificationAuthorizationStatusSingle()
          .flatMapCompletable { [unowned self] authorizationStatus in
            guard authorizationStatus.authorizationStatusIsSufficient else {
              return dependencies.notificationService.requestNotificationDeliveryAuthorization()
            }
            return Completable.create { handler in
              handler(.completed)
              return Disposables.create()
            }
          }
          .asObservable()
          .materialize()
          .withLatestFrom(dependencies.notificationService.createGetNotificationAuthorizationStatusSingle().asObservable())
          .map { $0.authorizationStatusIsSufficient }
      }
    // based on previous evaluation -> enable background fetch or disable background fetch and remove the app icon badge
      .do(onNext: { [unowned self] shouldDisplayBadge in
        setBackgroundFetchEnabled(shouldDisplayBadge)
        if !shouldDisplayBadge {
          clearAppIconBadge()
        }
      })
    // filter true -> app is allowed to send notifications
        .filter { $0 }
    // gather the latest information required for the app icon badge update
        .flatMapLatest { [unowned self] _ -> Observable<TemperatureOnAppIconBadgeInformation?> in
          dependencies.weatherStationService
            .createGetPreferredBookmarkObservable()
            .flatMapLatest { [unowned self] preferredBookmarkOption -> Observable<TemperatureOnAppIconBadgeInformation?> in
              guard let stationIdentifierInt = preferredBookmarkOption?.intValue else {
                return Observable.just(nil)
              }
              return Observable
                .combineLatest(
                  dependencies.weatherInformationService.createGetBookmarkedWeatherInformationItemObservable(for: String(stationIdentifierInt)).map { $0.entity },
                  dependencies.preferencesService.createGetTemperatureUnitOptionObservable(),
                  resultSelector: TemperatureOnAppIconBadgeInformation.init)
            }
        }
    // update the app icon badge with the latest weather information for the preferred bookmark
        .do(onNext: { [unowned self] temperatureOnAppIconBadgeInformation in
          guard let temperatureOnAppIconBadgeInformation = temperatureOnAppIconBadgeInformation else {
            clearAppIconBadge()
            return
          }
          _ = dependencies.notificationService
            .createPerformTemperatureOnBadgeUpdateCompletable(with: temperatureOnAppIconBadgeInformation)
            .subscribe()
        })
        .subscribe()
        .disposed(by: disposeBag)
  }
}

// MARK: - Helpers

private extension NotificationUpdateDaemon {
  
  func setBackgroundFetchEnabled(_ enabled: Bool) {
    DispatchQueue.main.async {
      UIApplication.shared.setMinimumBackgroundFetchInterval(enabled ? UIApplication.backgroundFetchIntervalMinimum : UIApplication.backgroundFetchIntervalNever)
    }
  }
  
  func clearAppIconBadge() {
    DispatchQueue.main.async {
      UIApplication.shared.applicationIconBadgeNumber = 0
    }
  }
}
