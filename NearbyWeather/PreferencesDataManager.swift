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

protocol StoredPreferencesProvider {
  var preferredBookmark: PreferredBookmarkOption { get set }
  var amountOfResults: AmountOfResultsOption { get set }
  var temperatureUnit: TemperatureUnitOption { get set }
  var distanceSpeedUnit: DistanceVelocityUnitOption { get set }
  var sortingOrientation: SortingOrientationOption { get set }
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
  
  private var locationAuthorizationObserver: NSObjectProtocol!
  
  // MARK: - Initialization
  
  private init(preferredBookmark: PreferredBookmarkOption, amountOfResults: AmountOfResultsOption, temperatureUnit: TemperatureUnitOption, windspeedUnit: DistanceVelocityUnitOption, sortingOrientation: SortingOrientationOption) {
    self.preferredBookmark = preferredBookmark
    self.amountOfResults = amountOfResults
    self.temperatureUnit = temperatureUnit
    self.distanceSpeedUnit = windspeedUnit
    self.sortingOrientation = sortingOrientation
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Public Properties & Methods
  
  static func instantiateSharedInstance() {
    shared = PreferencesDataManager.loadData() ?? PreferencesDataManager(preferredBookmark: PreferredBookmarkOption(value: .none),
                                                                         amountOfResults: AmountOfResultsOption(value: .ten),
                                                                         temperatureUnit: TemperatureUnitOption(value: .celsius),
                                                                         windspeedUnit: DistanceVelocityUnitOption(value: .kilometres),
                                                                         sortingOrientation: SortingOrientationOption(value: .name))
  }
  
  // MARK: - Preferences
  
  var preferredBookmark: PreferredBookmarkOption {
     didSet {
       BadgeService.shared.updateBadge()
       PreferencesDataManager.storeData()
     }
   }
   
   var amountOfResults: AmountOfResultsOption {
     didSet {
       WeatherDataManager.shared.update(withCompletionHandler: nil)
       PreferencesDataManager.storeData()
     }
   }
   
   var temperatureUnit: TemperatureUnitOption {
     didSet {
       BadgeService.shared.updateBadge()
       PreferencesDataManager.storeData()
     }
   }
   
   var distanceSpeedUnit: DistanceVelocityUnitOption {
     didSet {
       PreferencesDataManager.storeData()
     }
   }
   
   var sortingOrientation: SortingOrientationOption {
     didSet {
       NotificationCenter.default.post(
         name: Notification.Name(rawValue: Constants.Keys.NotificationCenter.kSortingOrientationPreferenceChanged),
         object: nil
       )
       PreferencesDataManager.storeData()
     }
   }
}

extension PreferencesDataManager: DataStorageProtocol {
  
  typealias T = PreferencesDataManager
  
  static func loadData() -> PreferencesDataManager? {
    guard let preferencesManagerStoredContentsWrapper = DataStorageManager.retrieveJsonFromFile(
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
  
  static func storeData() {
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
      DataStorageManager.storeJson(for: preferencesManagerStoredContentsWrapper,
                                   inFileWithName: Constants.Keys.Storage.kPreferencesManagerStoredContentsFileName,
                                   toStorageLocation: .applicationSupport)
      dispatchSemaphore.signal()
    }
  }
}
