//
//  PreferencesManager.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.02.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import Foundation
import UIKit

protocol PreferencesOption {
  associatedtype PreferencesOptionType
  var value: PreferencesOptionType { get set }
  init(value: PreferencesOptionType)
  init?(rawValue: Int)
  var stringValue: String { get }
}

class PreferredBookmark: Codable, PreferencesOption {
  typealias WrappedEnumType = Int?
  
  var value: Int?
  
  required  init(value: Int?) {
    self.value = value
  }
  
  convenience required  init?(rawValue: Int) { return nil }
  
  var stringValue: String {
    let bookmarkedLocation = WeatherDataManager.shared.bookmarkedLocations.first(where: { $0.identifier == value })
    return bookmarkedLocation?.name ?? R.string.localizable.none()
  }
}

enum SortingOrientationWrappedEnum: Int, CaseIterable, Codable {
  case name
  case temperature
  case distance
}

class SortingOrientation: Codable, PreferencesOption {
  typealias PreferencesOptionType = SortingOrientationWrappedEnum
  
  private lazy var count = {
    return SortingOrientationWrappedEnum.allCases.count
  }
  
  var value: SortingOrientationWrappedEnum
  
  required  init(value: SortingOrientationWrappedEnum) {
    self.value = value
  }
  
  convenience required  init?(rawValue: Int) {
    guard let value = SortingOrientationWrappedEnum(rawValue: rawValue) else {
      return nil
    }
    self.init(value: value)
  }
  
  var stringValue: String {
    switch value {
    case .name: return R.string.localizable.sortByName()
    case .temperature: return R.string.localizable.sortByTemperature()
    case .distance: return R.string.localizable.sortByDistance()
    }
  }
}

enum TemperatureUnitWrappedEnum: Int, CaseIterable, Codable {
  case celsius
  case fahrenheit
  case kelvin
}

class TemperatureUnit: Codable, PreferencesOption {
  typealias PreferencesOptionType = TemperatureUnitWrappedEnum
  
  private lazy var count: Int = {
    return TemperatureUnitWrappedEnum.allCases.count
  }()
  
  var value: TemperatureUnitWrappedEnum
  
  required init(value: TemperatureUnitWrappedEnum) {
    self.value = value
  }
  
  required convenience init?(rawValue: Int) {
    guard let value = TemperatureUnitWrappedEnum(rawValue: rawValue) else {
      return nil
    }
    self.init(value: value)
  }
  
  var stringValue: String {
    switch value {
    case .celsius: return Constants.Values.TemperatureName.kCelsius
    case .fahrenheit: return Constants.Values.TemperatureName.kFahrenheit
    case .kelvin: return Constants.Values.TemperatureName.kKelvin
    }
  }
  
  var abbreviation: String {
    switch value {
    case .celsius: return Constants.Values.TemperatureUnit.kCelsius
    case .fahrenheit: return Constants.Values.TemperatureUnit.kFahrenheit
    case .kelvin: return Constants.Values.TemperatureUnit.kKelvin
    }
  }
}

enum DistanceSpeedUnitWrappedEnum: Int, CaseIterable, Codable {
  case kilometres
  case miles
}

class DistanceSpeedUnit: Codable, PreferencesOption {
  typealias PreferencesOptionType = DistanceSpeedUnitWrappedEnum
  
  private lazy var count = {
    return DistanceSpeedUnitWrappedEnum.allCases.count
  }()
  
  var value: DistanceSpeedUnitWrappedEnum
  
  required init(value: DistanceSpeedUnitWrappedEnum) {
    self.value = value
  }
  
  required convenience init?(rawValue: Int) {
    guard let value = DistanceSpeedUnitWrappedEnum(rawValue: rawValue) else {
      return nil
    }
    self.init(value: value)
  }
  
  var stringValue: String {
    switch value {
    case .kilometres: return "\(R.string.localizable.metric())"
    case .miles: return "\(R.string.localizable.imperial())"
    }
  }
}

enum AmountOfResultsWrappedEnum: Int, CaseIterable, Codable {
  case ten
  case twenty
  case thirty
  case forty
  case fifty
}

class AmountOfResults: Codable, PreferencesOption {
  
  typealias PreferencesOptionType = AmountOfResultsWrappedEnum
  
  private lazy var count = {
    return AmountOfResultsWrappedEnum.allCases.count
  }()
  
  var value: AmountOfResultsWrappedEnum
  
  required init(value: AmountOfResultsWrappedEnum) {
    self.value = value
  }
  
  required convenience init?(rawValue: Int) {
    guard let value = AmountOfResultsWrappedEnum(rawValue: rawValue) else {
      return nil
    }
    self.init(value: value)
  }
  
  var stringValue: String {
    switch value {
    case .ten: return "\(10) \(R.string.localizable.results())"
    case .twenty: return "\(20) \(R.string.localizable.results())"
    case .thirty: return "\(30) \(R.string.localizable.results())"
    case .forty: return "\(40) \(R.string.localizable.results())"
    case .fifty: return "\(50) \(R.string.localizable.results())"
    }
  }
  
  var integerValue: Int {
    switch value {
    case .ten: return 10
    case .twenty: return 20
    case .thirty: return 30
    case .forty: return 40
    case .fifty: return 50
    }
  }
}

struct PreferencesManagerStoredContentsWrapper: Codable {
  var preferredBookmark: PreferredBookmark
  var amountOfResults: AmountOfResults
  var temperatureUnit: TemperatureUnit
  var windspeedUnit: DistanceSpeedUnit
  var sortingOrientation: SortingOrientation
}

final class PreferencesManager {
  
  private static let preferencesManagerBackgroundQueue = DispatchQueue(
    label: Constants.Labels.DispatchQueues.kPreferencesManagerBackgroundQueue,
    qos: .utility,
    attributes: [.concurrent],
    autoreleaseFrequency: .inherit,
    target: nil
  )
  
  // MARK: - Public Assets
  
  static var shared: PreferencesManager!
  
  // MARK: - Properties
  
  var preferredBookmark: PreferredBookmark {
    didSet {
      BadgeService.shared.updateBadge()
      PreferencesManager.storeService()
    }
  }
  var amountOfResults: AmountOfResults {
    didSet {
      WeatherDataManager.shared.update(withCompletionHandler: nil)
      PreferencesManager.storeService()
    }
  }
  var temperatureUnit: TemperatureUnit {
    didSet {
      BadgeService.shared.updateBadge()
      PreferencesManager.storeService()
    }
  }
  var distanceSpeedUnit: DistanceSpeedUnit {
    didSet {
      PreferencesManager.storeService()
    }
  }
  
  var sortingOrientation: SortingOrientation {
    didSet {
      NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.Keys.NotificationCenter.kSortingOrientationPreferenceChanged), object: self)
      PreferencesManager.storeService()
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
    
    locationAuthorizationObserver = NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil, using: { [unowned self] _ in
      self.reconfigureSortingPreferenceIfNeeded()
    })
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Public Properties & Methods
  
  static func instantiateSharedInstance() {
    shared = PreferencesManager.loadService() ?? PreferencesManager(preferredBookmark: PreferredBookmark(value: .none),
                                                                    amountOfResults: AmountOfResults(value: .ten),
                                                                    temperatureUnit: TemperatureUnit(value: .celsius),
                                                                    windspeedUnit: DistanceSpeedUnit(value: .kilometres),
                                                                    sortingOrientation: SortingOrientation(value: .name))
  }
  
  // MARK: - Private Helper Methods
  
  /* NotificationCenter Notifications */
  
  @objc private func reconfigureSortingPreferenceIfNeeded() {
    if !LocationService.shared.locationPermissionsGranted
      && sortingOrientation.value == .distance {
      sortingOrientation.value = .name // set to default
    }
  }
  
  /* Internal Storage Helpers */
  
  private static func loadService() -> PreferencesManager? {
    guard let preferencesManagerStoredContentsWrapper = DataStorageService.retrieveJsonFromFile(
      with: Constants.Keys.Storage.kPreferencesManagerStoredContentsFileName,
      andDecodeAsType: PreferencesManagerStoredContentsWrapper.self,
      fromStorageLocation: .applicationSupport
      ) else {
        return nil
    }
    
    return PreferencesManager(
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
        preferredBookmark: PreferencesManager.shared.preferredBookmark,
        amountOfResults: PreferencesManager.shared.amountOfResults,
        temperatureUnit: PreferencesManager.shared.temperatureUnit,
        windspeedUnit: PreferencesManager.shared.distanceSpeedUnit,
        sortingOrientation: PreferencesManager.shared.sortingOrientation
      )
      DataStorageService.storeJson(for: preferencesManagerStoredContentsWrapper,
                                   inFileWithName: Constants.Keys.Storage.kPreferencesManagerStoredContentsFileName,
                                   toStorageLocation: .applicationSupport)
      dispatchSemaphore.signal()
    }
  }
}
