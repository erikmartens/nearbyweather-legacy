//
//  PreferencesManager.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.02.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import Foundation

public protocol PreferencesOption {
    associatedtype WrappedEnumType
    var value: WrappedEnumType { get set }
    init(value: WrappedEnumType)
    init?(rawValue: Int)
    var stringValue: String { get }
}

public struct LightCityStruct: Codable {
    let id: Int
    let title: String
}

public enum PrefferedBookmarkWrappedEnum: Codable, Equatable {
    case none
    case city(LightCityStruct)
    
    // Codable
    
    enum CodingKeys: CodingKey {
        case none
        case city
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .none:
            try container.encode(-1, forKey: .none)
        case .city(let city):
            try container.encode(city, forKey: .city)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            _ = try container.decode(Int.self, forKey: .none)
            self = .none
        } catch {
            let cityValue = try container.decode(LightCityStruct.self, forKey: .city)
            self = .city(cityValue)
        }
    }
    
    // Equatable
    
    public static func == (lhs: PrefferedBookmarkWrappedEnum, rhs: PrefferedBookmarkWrappedEnum) -> Bool {
        if case .none = lhs, case .none = rhs { return true }
        if case let .city(lCity) = lhs, case let .city(rCity) = rhs, lCity.id == rCity.id { return true }
        return false
    }
}

public class PrefferedBookmark: Codable, PreferencesOption {
    public typealias WrappedEnumType = PrefferedBookmarkWrappedEnum
    
    public var value: PrefferedBookmarkWrappedEnum
    
    required public init(value: PrefferedBookmarkWrappedEnum) {
        self.value = value
    }
    
    convenience required public init?(rawValue: Int) { return nil }
    
    public var stringValue: String {
        switch value {
        case .none:
            return R.string.localizable.none()
        case .city(let city):
            return city.title
        }
    }
}


public enum SortingOrientationWrappedEnum: Int, Codable {
    case name
    case temperature
    case distance
}

public class SortingOrientation: Codable, PreferencesOption {
    public typealias WrappedEnumType = SortingOrientationWrappedEnum
    
    static let count = 3
    
    public var value: SortingOrientationWrappedEnum
    
    required public init(value: SortingOrientationWrappedEnum) {
        self.value = value
    }
    
    convenience required public init?(rawValue: Int) {
        guard let value = SortingOrientationWrappedEnum(rawValue: rawValue) else {
            return nil
        }
        self.init(value: value)
    }
    
    public var stringValue: String {
        switch value {
        case .name: return R.string.localizable.sortByName()
        case .temperature: return R.string.localizable.sortByTemperature()
        case .distance: return R.string.localizable.sortByDistance()
        }
    }
}

public enum TemperatureUnitWrappedEnum: Int, Codable {
    case celsius
    case fahrenheit
    case kelvin
}

public class TemperatureUnit: Codable, PreferencesOption {
    public typealias WrappedEnumType = TemperatureUnitWrappedEnum
    
    static let count = 3
    
    public var value: TemperatureUnitWrappedEnum
    
    public required init(value: TemperatureUnitWrappedEnum) {
        self.value = value
    }
    
    public required convenience init?(rawValue: Int) {
        guard let value = TemperatureUnitWrappedEnum(rawValue: rawValue) else {
            return nil
        }
        self.init(value: value)
    }
    
    public var stringValue: String {
        switch value {
        case .celsius: return "Celsius"
        case .fahrenheit: return "Fahrenheit"
        case .kelvin: return "Kelvin"
        }
    }
}

public enum DistanceSpeedUnitWrappedEnum: Int, Codable {
    case kilometres
    case miles
}

public class DistanceSpeedUnit: Codable, PreferencesOption {
    public typealias WrappedEnumType = DistanceSpeedUnitWrappedEnum
    
    static let count = 2
    
    public var value: DistanceSpeedUnitWrappedEnum
    
    public required init(value: DistanceSpeedUnitWrappedEnum) {
        self.value = value
    }
    
    public required convenience init?(rawValue: Int) {
        guard let value = DistanceSpeedUnitWrappedEnum(rawValue: rawValue) else {
            return nil
        }
        self.init(value: value)
    }
    
    public var stringValue: String {
        switch value {
        case .kilometres: return "\(R.string.localizable.metric())"
        case .miles: return "\(R.string.localizable.imperial())"
        }
    }
}

public enum AmountOfResultsWrappedEnum: Int, Codable {
    case ten
    case twenty
    case thirty
    case forty
    case fifty
}

public class AmountOfResults: Codable, PreferencesOption {
    public typealias WrappedEnumType = AmountOfResultsWrappedEnum
    
    static let count = 5
    
    public var value: AmountOfResultsWrappedEnum
    
    public required init(value: AmountOfResultsWrappedEnum) {
        self.value = value
    }
    
    public required convenience init?(rawValue: Int) {
        guard let value = AmountOfResultsWrappedEnum(rawValue: rawValue) else {
            return nil
        }
        self.init(value: value)
    }
    
    public var stringValue: String {
        switch value {
        case .ten: return "\(10) \(R.string.localizable.results())"
        case .twenty: return "\(20) \(R.string.localizable.results())"
        case .thirty: return "\(30) \(R.string.localizable.results())"
        case .forty: return "\(40) \(R.string.localizable.results())"
        case .fifty: return "\(50) \(R.string.localizable.results())"
        }
    }
    
    public var integerValue: Int {
        switch value {
        case .ten: return 10
        case .twenty: return 20
        case .thirty: return 30
        case .forty: return 40
        case .fifty: return 50
        }
    }
}

fileprivate let kPreferencesManagerStoredContentsFileName = "PreferencesManagerStoredContents"

struct PreferencesManagerStoredContentsWrapper: Codable {
    var prefferedBookmark: PrefferedBookmark
    var amountOfResults: AmountOfResults
    var temperatureUnit: TemperatureUnit
    var windspeedUnit: DistanceSpeedUnit
    var sortingOrientation: SortingOrientation
}

class PreferencesManager {
    
    // MARK: - Public Assets
    
    public static var shared: PreferencesManager!
    
    
    // MARK: - Properties
    
    public var prefferedBookmark: PrefferedBookmark {
        didSet {
            BadgeService.shared.updateBadge(withCompletionHandler: nil)
            PreferencesManager.storeService()
        }
    }
    public var amountOfResults: AmountOfResults {
        didSet {
            WeatherDataManager.shared.update(withCompletionHandler: nil)
            PreferencesManager.storeService()
        }
    }
    public var temperatureUnit: TemperatureUnit {
        didSet {
            BadgeService.shared.updateBadge(withCompletionHandler: nil)
            PreferencesManager.storeService()
        }
    }
    public var distanceSpeedUnit: DistanceSpeedUnit {
        didSet {
            PreferencesManager.storeService()
        }
    }
    
    public var sortingOrientation: SortingOrientation {
        didSet {
            NotificationCenter.default.post(name: Notification.Name(rawValue: kSortingOrientationPreferenceChanged), object: self)
            PreferencesManager.storeService()
        }
    }
    
    private var locationAuthorizationObserver: NSObjectProtocol!
    
    
    // MARK: - Initialization
    
    private init(prefferedBookmark: PrefferedBookmark, amountOfResults: AmountOfResults, temperatureUnit: TemperatureUnit, windspeedUnit: DistanceSpeedUnit, sortingOrientation: SortingOrientation) {
        self.prefferedBookmark = prefferedBookmark
        self.amountOfResults = amountOfResults
        self.temperatureUnit = temperatureUnit
        self.distanceSpeedUnit = windspeedUnit
        self.sortingOrientation = sortingOrientation
        
        locationAuthorizationObserver = NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationDidBecomeActive, object: nil, queue: nil, using: { [unowned self] notification in
            self.reconfigureSortingPreferenceIfNeeded()
        })
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Public Properties & Methods
    
    public static func instantiateSharedInstance() {
        shared = PreferencesManager.loadService() ?? PreferencesManager(prefferedBookmark: PrefferedBookmark(value: .none), amountOfResults: AmountOfResults(value: .ten), temperatureUnit: TemperatureUnit(value: .celsius), windspeedUnit: DistanceSpeedUnit(value: .kilometres), sortingOrientation: SortingOrientation(value: .name))
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
        guard let preferencesManagerStoredContentsWrapper = DataStorageService.retrieveJson(fromFileWithName: kPreferencesManagerStoredContentsFileName, andDecodeAsType: PreferencesManagerStoredContentsWrapper.self, fromStorageLocation: .applicationSupport) else {
            return nil
        }
        
        let preferencesManager = PreferencesManager(prefferedBookmark: preferencesManagerStoredContentsWrapper.prefferedBookmark,
                                                    amountOfResults: preferencesManagerStoredContentsWrapper.amountOfResults,
                                                    temperatureUnit: preferencesManagerStoredContentsWrapper.temperatureUnit,
                                                    windspeedUnit: preferencesManagerStoredContentsWrapper.windspeedUnit,
                                                    sortingOrientation: preferencesManagerStoredContentsWrapper.sortingOrientation)
        
        return preferencesManager
    }
    
    private static func storeService() {
        let preferencesManagerBackgroundQueue = DispatchQueue(label: "de.erikmaximilianmartens.nearbyWeather.preferencesManagerBackgroundQueue", qos: .utility, attributes: [DispatchQueue.Attributes.concurrent], autoreleaseFrequency: .inherit, target: nil)
        
        let dispatchSemaphore = DispatchSemaphore(value: 1)
        
        dispatchSemaphore.wait()
        preferencesManagerBackgroundQueue.async {
            let preferencesManagerStoredContentsWrapper = PreferencesManagerStoredContentsWrapper(prefferedBookmark: PreferencesManager.shared.prefferedBookmark,
                                                                                                  amountOfResults: PreferencesManager.shared.amountOfResults,
                                                                                                  temperatureUnit: PreferencesManager.shared.temperatureUnit,
                                                                                                  windspeedUnit: PreferencesManager.shared.distanceSpeedUnit,
                                                                                                  sortingOrientation: PreferencesManager.shared.sortingOrientation)
            DataStorageService.storeJson(forCodable: preferencesManagerStoredContentsWrapper, inFileWithName: kPreferencesManagerStoredContentsFileName, toStorageLocation: .applicationSupport)
            dispatchSemaphore.signal()
        }
    }
}
