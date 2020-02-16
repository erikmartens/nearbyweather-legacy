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
  var preferredBookmark: PreferredBookmark
  var amountOfResults: AmountOfResults
  var temperatureUnit: TemperatureUnit
  var windspeedUnit: DistanceSpeedUnit
  var sortingOrientation: SortingOrientation
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
  
  var preferredBookmark: PreferredBookmark {
    didSet {
      BadgeService.shared.updateBadge()
      PreferencesDataManager.storeService()
    }
  }
  var amountOfResults: AmountOfResults {
    didSet {
      WeatherDataManager.shared.update(withCompletionHandler: nil)
      PreferencesDataManager.storeService()
    }
  }
  var temperatureUnit: TemperatureUnit {
    didSet {
      BadgeService.shared.updateBadge()
      PreferencesDataManager.storeService()
    }
  }
  var distanceSpeedUnit: DistanceSpeedUnit {
    didSet {
      PreferencesDataManager.storeService()
    }
  }
  
  var sortingOrientation: SortingOrientation {
    didSet {
      NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.Keys.NotificationCenter.kSortingOrientationPreferenceChanged), object: nil)
      PreferencesDataManager.storeService()
    }
  }
  
  private var locationAuthorizationObserver: NSObjectProtocol!
  
  // MARK: - Initialization
  
  private init(preferredBookmark: PreferredBookmark, amountOfResults: AmountOfResults, temperatureUnit: TemperatureUnit, windspeedUnit: DistanceSpeedUnit, sortingOrientation: SortingOrientation) {
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
    shared = PreferencesDataManager.loadService() ?? PreferencesDataManager(preferredBookmark: PreferredBookmark(value: .none),
                                                                    amountOfResults: AmountOfResults(value: .ten),
                                                                    temperatureUnit: TemperatureUnit(value: .celsius),
                                                                    windspeedUnit: DistanceSpeedUnit(value: .kilometres),
                                                                    sortingOrientation: SortingOrientation(value: .name))
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
