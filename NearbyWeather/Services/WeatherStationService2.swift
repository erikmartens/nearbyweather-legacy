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

// MARK: - Dependencies

extension WeatherStationService2 {
  struct Dependencies {
    let preferencesService: PreferencesService2
  }
}
 
// MARK: - Class Definition

final class WeatherStationService2 {
  
  // MARK: - Assets
  
  private lazy var persistencyWorker: RealmPersistencyWorker = {
    try! RealmPersistencyWorker(
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
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  // MARK: - Initialization
  
  init(dependencies: WeatherStationService2.Dependencies) {
    self.dependencies = dependencies
  }
}

// MARK: - Weather Station Bookmark Settings

protocol WeatherStationBookmarkSettings {
  func addBookmark(_ weatherStationDto: WeatherStationDTO) -> Completable
  func removeBookmark(_ weatherStationDto: WeatherStationDTO) -> Completable
  func createBookmarkedStationsObservable() -> Observable<[WeatherStationDTO]>
  
  func setBookmarksSorting(_ sorting: [String: Int]) -> Completable
  func getBookmarksSorting() -> Observable<[String: Int]?>
  
  func setPreferredBookmark(_ weatherStationDto: PreferredBookmarkOption) -> Completable
  func clearPreferredBookmark() -> Completable
  func createPreferredBookmarkObservable() -> Observable<PreferredBookmarkOption?>
}

extension WeatherStationService2: WeatherStationBookmarkSettings {
  
  func addBookmark(_ weatherStationDto: WeatherStationDTO) -> Completable {
    Single
      .just(weatherStationDto)
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
  
  func removeBookmark(_ weatherStationDto: WeatherStationDTO) -> Completable {
    Single
      .just(weatherStationDto.identifier)
      .map {
        PersistencyModelIdentity(
          collection: WeatherStationService2.PersistencyKeys.weatherStationBookmarks.collection,
          identifier: String($0)
        )
      }
      .flatMapCompletable { [unowned persistencyWorker] in persistencyWorker.deleteResource(with: $0) }
  }
  
  func setBookmarksSorting(_ sorting: [String: Int]) -> Completable {
    Single
      .just(sorting)
      .map {
        PersistencyModel(
          identity: PersistencyModelIdentity(
            collection: WeatherStationService2.PersistencyKeys.weatherStationBookmarksSorting.collection,
            identifier: WeatherStationService2.PersistencyKeys.weatherStationBookmarksSorting.identifier
          ),
          entity: $0
        )
      }
      .flatMapCompletable { [unowned persistencyWorker] in persistencyWorker.saveResource($0, type: [String: Int].self) }
  }
  
  func getBookmarksSorting() -> Observable<[String: Int]?> {
    persistencyWorker
      .observeResource(
        with: PersistencyModelIdentity(
          collection: WeatherStationService2.PersistencyKeys.weatherStationBookmarksSorting.collection,
          identifier: WeatherStationService2.PersistencyKeys.weatherStationBookmarksSorting.identifier
        ),
        type: [String: Int].self
      )
      .map { $0?.entity }
  }
  
  func createBookmarkedStationsObservable() -> Observable<[WeatherStationDTO]> {
    persistencyWorker
      .observeResources(in: WeatherStationService2.PersistencyKeys.weatherStationBookmarks.collection, type: WeatherStationDTO.self)
      .map { $0.map { $0.entity } }
  }
  
  func setPreferredBookmark(_ weatherStationDto: PreferredBookmarkOption) -> Completable {
    Single
      .just(weatherStationDto)
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
  
  func clearPreferredBookmark() -> Completable {
    persistencyWorker
      .deleteResource(
        with: PersistencyModelIdentity(
          collection: WeatherStationService2.PersistencyKeys.weatherStationPreferredBookmark.collection,
          identifier: WeatherStationService2.PersistencyKeys.weatherStationPreferredBookmark.identifier
        )
      )
  }
  
  func createPreferredBookmarkObservable() -> Observable<PreferredBookmarkOption?> {
    persistencyWorker
      .observeResources(in: WeatherStationService2.PersistencyKeys.weatherStationPreferredBookmark.collection, type: PreferredBookmarkOption.self)
      .map { $0.first }
      .errorOnNil()
      .map { $0.entity }
      .catchErrorJustReturn(nil)
  }
}

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
      .flatMapLatest { [unowned self] weatherStationDtos -> Observable<[WeatherStationDTO]> in
        self
          .createBookmarkedStationsObservable()
          .map { bookmarkedWeatherStations in weatherStationDtos.filter { !bookmarkedWeatherStations.contains($0) } }
      }
      .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
  }
}
