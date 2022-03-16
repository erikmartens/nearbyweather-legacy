//
//  WeatherStationService2.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 30.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import FMDB
import RxSwift
import RxOptional

// MARK: - Persistency Keys

private extension WeatherStationService {
  enum PersistencyKeys {
    case weatherStationBookmarks
    case weatherStationBookmarksSorting
    case weatherStationPreferredBookmark
    
    var collection: String {
      switch self {
      case .weatherStationBookmarks: return "/weather_stations/bookmarks/"
      case .weatherStationBookmarksSorting: return "/weather_stations/bookmarks_sorting/"
      case .weatherStationPreferredBookmark: return "/weather_stations/preferred_bookmark/"
      }
    }
    
    var identifier: String {
      switch self {
      case .weatherStationBookmarks: return "default"
      case .weatherStationBookmarksSorting: return "default"
      case .weatherStationPreferredBookmark: return "default"
      }
    }
  }
}
 
// MARK: - Dependencies

extension WeatherStationService {
  struct Dependencies {
    let persistencyService: PersistencyProtocol
  }
}

// MARK: - Class Definition

final class WeatherStationService {
  
  // MARK: - Assets
  
  private lazy var lookupWorker: FMDatabaseQueue = {
    FMDatabaseQueue(
      path: R.file.locationsSQLiteSqlite()!.path
    )!
  }()
  
  private static func lookupQuery(for searchTerm: String) -> String {
    "SELECT * FROM locations l WHERE (lower(name) LIKE '%\(searchTerm.lowercased())%') ORDER BY l.name, l.country"
  }
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }
}

extension WeatherStationService {
  
  func createAddBookmarkCompletable(_ weatherStationDTO: WeatherStationDTO) -> Completable {
    Single
      .just(weatherStationDTO)
      .map {
        PersistencyModel<WeatherStationDTO>(
          identity: PersistencyModelIdentity(
            collection: WeatherStationService.PersistencyKeys.weatherStationBookmarks.collection,
            identifier: String($0.identifier)
          ),
          entity: $0
        )
      }
      .flatMapCompletable { [dependencies] in dependencies.persistencyService.saveResource($0, type: WeatherStationDTO.self) }
  }
  
  func createRemoveBookmarkCompletable(_ weatherStationDTO: WeatherStationDTO) -> Completable {
    Observable
      .just(weatherStationDTO.identifier)
      .take(1)
      .do(onNext: { [unowned self] identifier in
        _ = createGetPreferredBookmarkObservable()
          .take(1)
          .filter { identifier == $0?.value.stationIdentifier }
          .asSingle()
          .flatMapCompletable { [unowned self] _ in
            self.createRemovePreferredBookmarkCompletable()
          }
          .subscribe()
      })
      .map {
        PersistencyModelIdentity(
          collection: WeatherStationService.PersistencyKeys.weatherStationBookmarks.collection,
          identifier: String($0)
        )
      }
      .asSingle()
      .flatMapCompletable { [dependencies] in dependencies.persistencyService.deleteResource(with: $0) }
  }
  
  func createSetBookmarkedStationsCompletable(_ weatherStationDTOs: [WeatherStationDTO]) -> Completable {
    Single
      .just(weatherStationDTOs)
      .map {
        $0.map {
          PersistencyModel(
            identity: PersistencyModelIdentity(
              collection: WeatherStationService.PersistencyKeys.weatherStationBookmarks.collection,
              identifier: String($0.identifier)
            ),
            entity: $0
          )
        }
      }
      .flatMapCompletable { [dependencies] in dependencies.persistencyService.saveResources($0, type: WeatherStationDTO.self) }
  }
  
  func createGetBookmarkedStationsObservable() -> Observable<[WeatherStationDTO]> {
    dependencies
      .persistencyService
      .observeResources(in: WeatherStationService.PersistencyKeys.weatherStationBookmarks.collection, type: WeatherStationDTO.self)
      .map { $0.map { $0.entity } }
  }
  
  func createGetIsStationBookmarkedObservable(for identity: PersistencyModelIdentity) -> Observable<Bool> {
    createGetBookmarkedStationsObservable()
      .map { $0.contains(where: { String($0.identifier) == identity.identifier }) }
  }
  
  func createSetBookmarksSortingCompletable(_ sorting: [Int: Int]) -> Completable {
    Single
      .just(sorting)
      .map {
        PersistencyModel(
          identity: PersistencyModelIdentity(
            collection: WeatherStationService.PersistencyKeys.weatherStationBookmarksSorting.collection,
            identifier: WeatherStationService.PersistencyKeys.weatherStationBookmarksSorting.identifier
          ),
          entity: $0.toArray()
        )
      }
      .flatMapCompletable { [dependencies] in dependencies.persistencyService.saveResource($0, type: [WeatherStationSortingOrientationDTO].self) }
  }
  
  func createGetBookmarksSortingObservable() -> Observable<[Int: Int]?> {
    dependencies
      .persistencyService
      .observeResource(
        with: PersistencyModelIdentity(
          collection: WeatherStationService.PersistencyKeys.weatherStationBookmarksSorting.collection,
          identifier: WeatherStationService.PersistencyKeys.weatherStationBookmarksSorting.identifier
        ),
        type: [WeatherStationSortingOrientationDTO].self
      )
      .map { $0?.entity.toDictionary() }
  }
  
  func createSetPreferredBookmarkCompletable(_ weatherStationDTO: PreferredBookmarkOption) -> Completable {
    Single
      .just(weatherStationDTO)
      .map {
        PersistencyModel(
          identity: PersistencyModelIdentity(
            collection: WeatherStationService.PersistencyKeys.weatherStationPreferredBookmark.collection,
            identifier: WeatherStationService.PersistencyKeys.weatherStationPreferredBookmark.identifier
          ),
          entity: $0
        )
      }
      .flatMapCompletable { [dependencies] in dependencies.persistencyService.saveResource($0, type: PreferredBookmarkOption.self) }
  }
  
  func createRemovePreferredBookmarkCompletable() -> Completable {
    dependencies
      .persistencyService
      .deleteResource(
        with: PersistencyModelIdentity(
          collection: WeatherStationService.PersistencyKeys.weatherStationPreferredBookmark.collection,
          identifier: WeatherStationService.PersistencyKeys.weatherStationPreferredBookmark.identifier
        )
      )
  }
  
  func createGetPreferredBookmarkObservable() -> Observable<PreferredBookmarkOption?> {
    dependencies
      .persistencyService
      .observeResources(
        in: WeatherStationService.PersistencyKeys.weatherStationPreferredBookmark.collection,
        type: PreferredBookmarkOption.self
      )
      .map { $0.first?.entity }
  }
  
  func createWeatherStationsLocalLookupObservable(for searchTerm: String) -> Observable<[WeatherStationDTO]> {
    Observable<[WeatherStationDTO]?>
      .create { [lookupWorker] subscriber in
        lookupWorker.inDatabase { database in
          guard let result = try? database.executeQuery(Self.lookupQuery(for: searchTerm), values: nil) else {
            subscriber.on(.next(nil))
            return
          }
          var retrievedStations = [WeatherStationDTO]()
          while result.next() {
            if let station = WeatherStationDTO(from: result) {
              retrievedStations.append(station)
            }
          }
          subscriber.on(.next(retrievedStations))
        }
        return Disposables.create()
      }
      .replaceNilWith([])
      .flatMapLatest { [unowned self] weatherStationDTOs -> Observable<[WeatherStationDTO]> in
        self
          .createGetBookmarkedStationsObservable()
          .map { bookmarkedWeatherStations in weatherStationDTOs.filter { !bookmarkedWeatherStations.contains($0) } }
      }
  }
}

// MARK: - Weather Station Bookmarks

protocol WeatherStationBookmarkPersistence: WeatherStationBookmarkSetting, WeatherStationBookmarkReading {}
extension WeatherStationService: WeatherStationBookmarkPersistence {}

protocol WeatherStationBookmarkSetting {
  func createAddBookmarkCompletable(_ weatherStationDTO: WeatherStationDTO) -> Completable
  func createRemoveBookmarkCompletable(_ weatherStationDTO: WeatherStationDTO) -> Completable
  func createSetBookmarkedStationsCompletable(_ weatherStationDTOs: [WeatherStationDTO]) -> Completable
  func createSetBookmarksSortingCompletable(_ sorting: [Int: Int]) -> Completable
  func createSetPreferredBookmarkCompletable(_ weatherStationDTO: PreferredBookmarkOption) -> Completable
  func createRemovePreferredBookmarkCompletable() -> Completable
}

extension WeatherStationService: WeatherStationBookmarkSetting {}

protocol WeatherStationBookmarkReading {
  func createGetBookmarkedStationsObservable() -> Observable<[WeatherStationDTO]>
  func createGetBookmarksSortingObservable() -> Observable<[Int: Int]?>
  func createGetPreferredBookmarkObservable() -> Observable<PreferredBookmarkOption?>
  func createGetIsStationBookmarkedObservable(for identity: PersistencyModelIdentity) -> Observable<Bool>
}

extension WeatherStationService: WeatherStationBookmarkReading {}

// MARK: - Weather Station Lookup

protocol WeatherStationLookup {
  func createWeatherStationsLocalLookupObservable(for searchTerm: String) -> Observable<[WeatherStationDTO]>
}

extension WeatherStationService: WeatherStationLookup {}

// MARK: Settings Preferences
/// Preferences that are available in the Settings Scene

protocol SettingsWeatherStationPersistence: SettingsWeatherStationSetting, SettingsWeatherStationReading {}
extension WeatherStationService: SettingsWeatherStationPersistence {}

protocol SettingsWeatherStationSetting {
  func createSetPreferredBookmarkCompletable(_ weatherStationDTO: PreferredBookmarkOption) -> Completable
}

extension WeatherStationService: SettingsWeatherStationSetting {}

protocol SettingsWeatherStationReading {
  func createGetPreferredBookmarkObservable() -> Observable<PreferredBookmarkOption?>
}

extension WeatherStationService: SettingsWeatherStationReading {}

// MARK: - Weather Station Bookmark Migration

protocol WeatherStationBookmarkMigration {
  func createSetBookmarkedStationsCompletable(_ weatherStationDTOs: [WeatherStationDTO]) -> Completable
  func createSetPreferredBookmarkCompletable(_ weatherStationDTO: PreferredBookmarkOption) -> Completable
  func createSetBookmarksSortingCompletable(_ sorting: [Int: Int]) -> Completable
}

extension WeatherStationService: WeatherStationBookmarkMigration {}

// MARK: - Helper Extensions

private extension Dictionary where Key == Int, Value == Int {
  
  func toArray() -> [WeatherStationSortingOrientationDTO] {
    keys.map { WeatherStationSortingOrientationDTO(stationIdentifier: $0, stationIndex: self[$0] ?? 999) }
  }
}

private extension Array where Element == WeatherStationSortingOrientationDTO {
  
  func toDictionary() -> [Int: Int] {
    reduce([Int: Int]()) { nextResult, nextValue -> [Int: Int] in
      var mutableNextResult = nextResult
      mutableNextResult[nextValue.stationIdentifier] = nextValue.stationIndex
      return mutableNextResult
    }
  }
}
