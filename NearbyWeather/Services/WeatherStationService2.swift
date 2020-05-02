//
//  WeatherStationService2.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 30.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

// TODO: Migration
// TODO: Store sort weighting

import FMDB
import RxSwift
import RxOptional

class WeatherStationService2 {
  
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
  
  private static let weatherStationBookmarkCollection = "/weather_station/bookmarked/"
  
  // MARK: - Properties
  
  // MARK: - Initialization
  
  init() {}
}

// MARK: - Weather Station Lookup

protocol WeatherStationLookup {
  func createWeatherStationsLookupObservable(for searchTerm: String) -> Observable<[WeatherStationDTO]>
}

extension WeatherStationService2: WeatherStationLookup {
  
  func createWeatherStationsLookupObservable(for searchTerm: String) -> Observable<[WeatherStationDTO]> {
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
      .flatMapLatest { [createBookmarkedStationsObservable] weatherStationDtos -> Observable<[WeatherStationDTO]> in
        createBookmarkedStationsObservable()
          .map { bookmarkedWeatherStations in
            weatherStationDtos.filter { !bookmarkedWeatherStations.contains($0) }
          }
      }
      .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
  }
}

// MARK: - Weather Station Bookmarking

protocol WeatherStationBookmarking {
  func addBookmark(_ weatherStationDto: WeatherStationDTO) -> Completable
  func removeBookmark(_ weatherStationDto: WeatherStationDTO) -> Completable
  func createBookmarkedStationsObservable() -> Observable<[WeatherStationDTO]>
}

extension WeatherStationService2: WeatherStationBookmarking {
  
  func addBookmark(_ weatherStationDto: WeatherStationDTO) -> Completable {
    Single
      .just(weatherStationDto)
      .map { weatherStationDto -> PersistencyModel<WeatherStationDTO> in
        PersistencyModel<WeatherStationDTO>(
          identity: PersistencyModelIdentity(
            collection: Self.weatherStationBookmarkCollection,
            identifier: String(weatherStationDto.identifier)),
          entity: weatherStationDto
        )
      }
      .flatMapCompletable { [persistencyWorker] in persistencyWorker.saveResource($0, type: WeatherStationDTO.self) }
  }
  
  func removeBookmark(_ weatherStationDto: WeatherStationDTO) -> Completable {
    Single
      .just(weatherStationDto.identifier)
      .map { PersistencyModelIdentity(collection: Self.weatherStationBookmarkCollection, identifier: String($0)) }
      .flatMapCompletable { [persistencyWorker] in persistencyWorker.deleteResource(with: $0) }
  }
  
  func createBookmarkedStationsObservable() -> Observable<[WeatherStationDTO]> {
    persistencyWorker
      .observeResources(in: Self.weatherStationBookmarkCollection, type: WeatherStationDTO.self)
      .map { $0.map { $0.entity } }
  }
}
