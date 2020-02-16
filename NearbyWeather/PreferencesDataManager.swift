//
//  PreferencesManager.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.02.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import Foundation
import UIKit

struct PreferencesManagerStoredContentsWrapper: Codable {
  var preferredBookmark: PreferredBookmarkOption
  var amountOfResults: AmountOfResultsOption
  var temperatureUnit: TemperatureUnitOption
  var windspeedUnit: DistanceVelocityUnitOption
  var sortingOrientation: SortingOrientationOption
}

final class PreferencesDataManager {
  
  private static let preferencesManagerBackgroundQueue = DispatchQueue(
    label: Constants.Labels.DispatchQueues.kPreferencesManagerBackgroundQueue,
    qos: .utility,
    attributes: [.concurrent],
    autoreleaseFrequency: .inherit,
    target: nil
  )
  
  // MARK: - Public Assets
  
  static var shared: PreferencesDataManager!
  
  // MARK: - Properties
  
  var preferredBookmark: PreferredBookmarkOption {
    didSet {
      BadgeService.shared.updateBadge()
      PreferencesDataManager.storeService()
    }
  }
  var amountOfResults: AmountOfResultsOption {
    didSet {
      WeatherDataManager.shared.update(withCompletionHandler: nil)
      PreferencesDataManager.storeService()
    }
  }
  var temperatureUnit: TemperatureUnitOption {
    didSet {
      BadgeService.shared.updateBadge()
      PreferencesDataManager.storeService()
    }
  }
  var distanceSpeedUnit: DistanceVelocityUnitOption {
    didSet {
      PreferencesDataManager.storeService()
    }
  }
  
  var sortingOrientation: SortingOrientationOption {
    didSet {
      NotificationCenter.default.post(
        name: Notification.Name(rawValue: Constants.Keys.NotificationCenter.kSortingOrientationPreferenceChanged),
        object: nil
      )
      PreferencesDataManager.storeService()
    }
  }
  
  private var locationAuthorizationObserver: NSObjectProtocol!
  
  // MARK: - Initialization
  
  private init(preferredBookmark: PreferredBookmarkOption, amountOfResults: AmountOfResultsOption, temperatureUnit: TemperatureUnitOption, windspeedUnit: DistanceVelocityUnitOption, sortingOrientation: SortingOrientationOption) {
    self.preferredBookmark = preferredBookmark
    self.amountOfResults = amountOfResults
    self.temperatureUnit = temperatureUnit
    self.distanceSpeedUnit = windspeedUnit
    self.sortingOrientation = sortingOrientation
    
    locationAuthorizationObserver = NotificationCenter.default.addObserver(
      forName: UIApplication.didBecomeActiveNotification,
      object: nil, queue: nil, using: { [unowned self] _ in
        self.reconfigureSortingPreferenceIfNeeded()
      }
    )
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Public Properties & Methods
  
  static func instantiateSharedInstance() {
    shared = PreferencesDataManager.loadService() ?? PreferencesDataManager(preferredBookmark: PreferredBookmarkOption(value: .none),
                                                                    amountOfResults: AmountOfResultsOption(value: .ten),
                                                                    temperatureUnit: TemperatureUnitOption(value: .celsius),
                                                                    windspeedUnit: DistanceVelocityUnitOption(value: .kilometres),
                                                                    sortingOrientation: SortingOrientationOption(value: .name))
  }
  
  // MARK: - Private Helper Methods
  
  /* NotificationCenter Notifications */
  
  @objc private func reconfigureSortingPreferenceIfNeeded() {
    if !UserLocationService.shared.locationPermissionsGranted
      && sortingOrientation.value == .distance {
      sortingOrientation.value = .name // set to default
    }
  }
  
  /* Internal Storage Helpers */
  
  private static func loadService() -> PreferencesDataManager? {
    guard let preferencesManagerStoredContentsWrapper = DataStorageService.retrieveJsonFromFile(
      with: Constants.Keys.Storage.kPreferencesManagerStoredContentsFileName,
      andDecodeAsType: PreferencesManagerStoredContentsWrapper.self,
      fromStorageLocation: .applicationSupport
      ) else {
        return nil
    }
    
    return PreferencesDataManager(
      preferredBookmark: preferencesManagerStoredContentsWrapper.preferredBookmark,
      amountOfResults: preferencesManagerStoredContentsWrapper.amountOfResults,
      temperatureUnit: preferencesManagerStoredContentsWrapper.temperatureUnit,
      windspeedUnit: preferencesManagerStoredContentsWrapper.windspeedUnit,
      sortingOrientation: preferencesManagerStoredContentsWrapper.sortingOrientation
    )
  }
  
  private static func storeService() {
    let dispatchSemaphore = DispatchSemaphore(value: 1)
    
    dispatchSemaphore.wait()
    preferencesManagerBackgroundQueue.async {
      let preferencesManagerStoredContentsWrapper = PreferencesManagerStoredContentsWrapper(
        preferredBookmark: PreferencesDataManager.shared.preferredBookmark,
        amountOfResults: PreferencesDataManager.shared.amountOfResults,
        temperatureUnit: PreferencesDataManager.shared.temperatureUnit,
        windspeedUnit: PreferencesDataManager.shared.distanceSpeedUnit,
        sortingOrientation: PreferencesDataManager.shared.sortingOrientation
      )
      DataStorageService.storeJson(for: preferencesManagerStoredContentsWrapper,
                                   inFileWithName: Constants.Keys.Storage.kPreferencesManagerStoredContentsFileName,
                                   toStorageLocation: .applicationSupport)
      dispatchSemaphore.signal()
    }
  }
}
