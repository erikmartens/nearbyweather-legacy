//
//  PreferencesService2.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 02.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

// TODO: Migration
// TODO: Store sort weighting

import RxSwift
import RxOptional

final class PreferencesService2 {
  
  // MARK: - Assets
  
  private lazy var persistencyWorker: RealmPersistencyWorker = {
    try! RealmPersistencyWorker(
      storageLocation: .documents,
      dataBaseFileName: "PreferencesServiceDataBase"
    )
  }()
  
  private static let weatherStationBookmarkCollection = "/weather_station/bookmarked/"
  private static let weatherStationPreferredCollection = "/weather_station/"
  private static let weatherStationPreferredIdentifier = "preferred"
  
  // MARK: - Properties
  
  // MARK: - Initialization
  
  init() {}
}

// MARK: - Weather Station Bookmarking

protocol WeatherStationBookmarking {
  func addBookmark(_ weatherStationDto: WeatherStationDTO) -> Completable
  func removeBookmark(_ weatherStationDto: WeatherStationDTO) -> Completable
  func createBookmarkedStationsObservable() -> Observable<[WeatherStationDTO]>
  
  func setPreferredBookmark(_ weatherStationDto: WeatherStationDTO) -> Completable
  func clearPreferredBookmark() -> Completable
  func createPreferredBookmarkObservable() -> Observable<WeatherStationDTO?>
}

extension PreferencesService2: WeatherStationBookmarking {
  
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
  
  func setPreferredBookmark(_ weatherStationDto: WeatherStationDTO) -> Completable {
    Single
      .just(weatherStationDto)
      .map {
        PersistencyModel(
          identity: PersistencyModelIdentity(
            collection: Self.weatherStationPreferredCollection,
            identifier: Self.weatherStationPreferredIdentifier
          ),
          entity: $0
        )
      }
      .flatMapCompletable { [persistencyWorker] persistencyModel -> Completable in
        persistencyWorker.saveResource(persistencyModel, type: WeatherStationDTO.self)
      }
  }
  
  func clearPreferredBookmark() -> Completable {
    persistencyWorker
      .deleteResource(with: PersistencyModelIdentity(
        collection: Self.weatherStationPreferredCollection,
        identifier: Self.weatherStationPreferredIdentifier
      ))
  }
  
  func createPreferredBookmarkObservable() -> Observable<WeatherStationDTO?> {
    persistencyWorker
      .observeResources(in: Self.weatherStationPreferredCollection, type: WeatherStationDTO.self)
      .map { $0.first }
      .errorOnNil()
      .map { $0.entity }
      .catchErrorJustReturn(nil)
  }
}
