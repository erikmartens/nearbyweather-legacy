//
//  PreferencesManager.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.02.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import MapKit

protocol StoredPreferencesProvider {
  var preferredBookmark: PreferredBookmarkOption { get set }
  var amountOfResults: AmountOfResultsOption { get set }
  var temperatureUnit: TemperatureUnitOption { get set }
  var distanceSpeedUnit: DimensionalUnitOption { get set }
  var sortingOrientation: SortingOrientationOption { get set }
}

protocol InMemoryPreferencesProvider {
  var preferredListType: ListTypeOptionValue { get set }
  var preferredMapType: MKMapType { get set }
}

final class PreferencesService: StoredPreferencesProvider, InMemoryPreferencesProvider {
  
  private static let preferencesManagerBackgroundQueue = DispatchQueue(
    label: Constants.Labels.DispatchQueues.kPreferencesManagerBackgroundQueue,
    qos: .utility,
    attributes: [.concurrent],
    autoreleaseFrequency: .inherit,
    target: nil
  )
  
  // MARK: - Public Assets
  
  static var shared: PreferencesService!
  
  // MARK: - Properties
  
  private var locationAuthorizationObserver: NSObjectProtocol!
  
  // MARK: - Initialization
  
  private init(preferredBookmark: PreferredBookmarkOption, amountOfResults: AmountOfResultsOption, temperatureUnit: TemperatureUnitOption, windspeedUnit: DimensionalUnitOption, sortingOrientation: SortingOrientationOption) {
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
    shared = PreferencesService.loadData() ?? PreferencesService(preferredBookmark: PreferredBookmarkOption(value: .notSet),
                                                                         amountOfResults: AmountOfResultsOption(value: .ten),
                                                                         temperatureUnit: TemperatureUnitOption(value: .celsius),
                                                                         windspeedUnit: DimensionalUnitOption(value: .metric),
                                                                         sortingOrientation: SortingOrientationOption(value: .name))
  }
  
  // MARK: - Stored Preferences
  
  var preferredBookmark: PreferredBookmarkOption {
    didSet {
      BadgeService.shared.updateBadge()
      PreferencesService.storeData()
    }
  }
  
  var amountOfResults: AmountOfResultsOption {
    didSet {
      WeatherInformationService.shared.update(withCompletionHandler: nil)
      PreferencesService.storeData()
    }
  }
  
  var temperatureUnit: TemperatureUnitOption {
    didSet {
      BadgeService.shared.updateBadge()
      PreferencesService.storeData()
    }
  }
  
  var distanceSpeedUnit: DimensionalUnitOption {
    didSet {
      PreferencesService.storeData()
    }
  }
  
  var sortingOrientation: SortingOrientationOption {
    didSet {
      NotificationCenter.default.post(
        name: Notification.Name(rawValue: Constants.Keys.NotificationCenter.kSortingOrientationPreferenceChanged),
        object: nil
      )
      PreferencesService.storeData()
    }
  }
  
  // MARK: - In Memory Preferences
  
  var preferredListType: ListTypeOptionValue = .bookmarked
  
  var preferredMapType: MKMapType = .standard
}

extension PreferencesService: JsonPersistencyProtocol {
  
  typealias StorageEntity = PreferencesService
  
  static func loadData() -> PreferencesService? {
    guard let preferencesManagerStoredContentsWrapper = try? JsonPersistencyWorker().retrieveJsonFromFile(
      with: Constants.Keys.Storage.kPreferencesManagerStoredContentsFileName,
      andDecodeAsType: PreferencesManagerStoredContentsWrapper.self,
      fromStorageLocation: .applicationSupport
      ) else {
        return nil
    }
    
    return PreferencesService(
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
        preferredBookmark: PreferencesService.shared.preferredBookmark,
        amountOfResults: PreferencesService.shared.amountOfResults,
        temperatureUnit: PreferencesService.shared.temperatureUnit,
        windspeedUnit: PreferencesService.shared.distanceSpeedUnit,
        sortingOrientation: PreferencesService.shared.sortingOrientation
      )
      try? JsonPersistencyWorker().storeJson(
        for: preferencesManagerStoredContentsWrapper,
        inFileWithName: Constants.Keys.Storage.kPreferencesManagerStoredContentsFileName,
        toStorageLocation: .applicationSupport
      )
      dispatchSemaphore.signal()
    }
  }
}
