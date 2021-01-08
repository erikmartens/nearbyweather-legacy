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

private extension WeatherStationService2 {
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
 
// MARK: - Class Definition

final class WeatherStationService2 {
  
  // MARK: - Assets
  
  private lazy var persistencyWorker: RealmPersistencyWorker = {
    try! RealmPersistencyWorker( // swiftlint:disable:this force_try
      storageLocation: .documents,
      dataBaseFileName: "WeatherStationServiceDataBase"
    )
  }()
  
  private lazy var lookupWorker: FMDatabaseQueue = {
    FMDatabaseQueue(
      path: R.file.locationsSQLiteSqlite()!.path
    )!
  }()
  
  private static func lookupQuery(for searchTerm: String) -> String {
    "SELECT * FROM locations l WHERE (lower(name) LIKE '%\(searchTerm.lowercased())%') ORDER BY l.name, l.country"
  }
}

// MARK: - Weather Station Bookmark Settings

protocol WeatherStationBookmarkPersistence {
  func createAddBookmarkCompletable(_ weatherStationDTO: WeatherStationDTO) -> Completable
  func createRemoveBookmarkCompletable(_ weatherStationDTO: WeatherStationDTO) -> Completable
 
  func createSetBookmarkedStationsCompletable(_ weatherStationDTOs: [WeatherStationDTO]) -> Completable
  func createGetBookmarkedStationsObservable() -> Observable<[WeatherStationDTO]>
  
  func createSetBookmarksSortingCompletable(_ sorting: [Int: Int]) -> Completable
  func createGetBookmarksSortingObservable() -> Observable<[Int: Int]?>
  
  func createSetPreferredBookmarkCompletable(_ weatherStationDTO: PreferredBookmarkOption) -> Completable
  func createRemovePreferredBookmarkCompletable() -> Completable
  func createGetPreferredBookmarkObservable() -> Observable<PreferredBookmarkOption?>
}

extension WeatherStationService2: WeatherStationBookmarkPersistence {
  
  func createAddBookmarkCompletable(_ weatherStationDTO: WeatherStationDTO) -> Completable {
    Single
      .just(weatherStationDTO)
      .map {
        PersistencyModel<WeatherStationDTO>(
          identity: PersistencyModelIdentity(
            collection: WeatherStationService2.PersistencyKeys.weatherStationBookmarks.collection,
            identifier: String($0.identifier)
          ),
          entity: $0
        )
      }
      .flatMapCompletable { [unowned persistencyWorker] in persistencyWorker.saveResource($0, type: WeatherStationDTO.self) }
  }
  
  func createRemoveBookmarkCompletable(_ weatherStationDTO: WeatherStationDTO) -> Completable {
    Single
      .just(weatherStationDTO.identifier)
      .map {
        PersistencyModelIdentity(
          collection: WeatherStationService2.PersistencyKeys.weatherStationBookmarks.collection,
          identifier: String($0)
        )
      }
      .flatMapCompletable { [unowned persistencyWorker] in persistencyWorker.deleteResource(with: $0) }
  }
  
  func createSetBookmarkedStationsCompletable(_ weatherStationDTOs: [WeatherStationDTO]) -> Completable {
    Single
      .just(weatherStationDTOs)
      .map {
        $0.map {
          PersistencyModel(
            identity: PersistencyModelIdentity(
              collection: WeatherStationService2.PersistencyKeys.weatherStationBookmarks.collection,
              identifier: String($0.identifier)
            ),
            entity: $0
          )
        }
      }
      .flatMapCompletable { [unowned persistencyWorker] in persistencyWorker.saveResources($0, type: WeatherStationDTO.self) }
  }
  
  func createGetBookmarkedStationsObservable() -> Observable<[WeatherStationDTO]> {
    persistencyWorker
      .observeResources(in: WeatherStationService2.PersistencyKeys.weatherStationBookmarks.collection, type: WeatherStationDTO.self)
      .map { $0.map { $0.entity } }
  }
  
  func createSetBookmarksSortingCompletable(_ sorting: [Int: Int]) -> Completable {
    Single
      .just(sorting)
      .map {
        PersistencyModel(
          identity: PersistencyModelIdentity(
            collection: WeatherStationService2.PersistencyKeys.weatherStationBookmarksSorting.collection,
            identifier: WeatherStationService2.PersistencyKeys.weatherStationBookmarksSorting.identifier
          ),
          entity: $0.toArray()
        )
      }
      .flatMapCompletable { [unowned persistencyWorker] in persistencyWorker.saveResource($0, type: [WeatherStationSortingOrientationDTO].self) }
  }
  
  func createGetBookmarksSortingObservable() -> Observable<[Int: Int]?> {
    persistencyWorker
      .observeResource(
        with: PersistencyModelIdentity(
          collection: WeatherStationService2.PersistencyKeys.weatherStationBookmarksSorting.collection,
          identifier: WeatherStationService2.PersistencyKeys.weatherStationBookmarksSorting.identifier
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
            collection: WeatherStationService2.PersistencyKeys.weatherStationPreferredBookmark.collection,
            identifier: WeatherStationService2.PersistencyKeys.weatherStationPreferredBookmark.identifier
          ),
          entity: $0
        )
      }
      .flatMapCompletable { [unowned persistencyWorker] in persistencyWorker.saveResource($0, type: PreferredBookmarkOption.self) }
  }
  
  func createRemovePreferredBookmarkCompletable() -> Completable {
    persistencyWorker
      .deleteResource(
        with: PersistencyModelIdentity(
          collection: WeatherStationService2.PersistencyKeys.weatherStationPreferredBookmark.collection,
          identifier: WeatherStationService2.PersistencyKeys.weatherStationPreferredBookmark.identifier
        )
      )
  }
  
  func createGetPreferredBookmarkObservable() -> Observable<PreferredBookmarkOption?> {
    persistencyWorker
      .observeResources(in: WeatherStationService2.PersistencyKeys.weatherStationPreferredBookmark.collection, type: PreferredBookmarkOption.self)
      .map { $0.first }
      .errorOnNil()
      .map { $0.entity }
      .catchErrorJustReturn(nil)
  }
}

// MARK: - Weather Station Bookmark Sorting Reading

protocol WeatherStationBookmarkReading {
  func createGetBookmarkedStationsObservable() -> Observable<[WeatherStationDTO]>
  func createGetBookmarksSortingObservable() -> Observable<[Int: Int]?>
  func createGetPreferredBookmarkObservable() -> Observable<PreferredBookmarkOption?>
}

extension WeatherStationService2: WeatherStationBookmarkReading {}

// MARK: - Weather Station Lookup

protocol WeatherStationLookup {
  func createWeatherStationsLocalLookupObservable(for searchTerm: String) -> Observable<[WeatherStationDTO]>
}

extension WeatherStationService2: WeatherStationLookup {
  
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
      .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
  }
}

// MARK: - Weather Station Bookmark Migration

protocol WeatherStationBookmarkMigration {
  func createSetBookmarkedStationsCompletable(_ weatherStationDTOs: [WeatherStationDTO]) -> Completable
  func createSetPreferredBookmarkCompletable(_ weatherStationDTO: PreferredBookmarkOption) -> Completable
  func createSetBookmarksSortingCompletable(_ sorting: [Int: Int]) -> Completable
  
}

extension WeatherStationService2: WeatherStationBookmarkMigration {}

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
