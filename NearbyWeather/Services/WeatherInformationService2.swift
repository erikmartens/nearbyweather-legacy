//
//  WeatherInformationService2.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 29.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxSwift

final class WeatherInformationService2 {
  
  static let shared = WeatherInformationService2()
  
  // MARK: - Properties
  
  private lazy var persistencyWorker: RealmPersistencyWorker = {
    try! RealmPersistencyWorker(
      storageLocation: .documents,
      dataBaseFileName: "WeatherInformationDataBase"
    )
  }()
  
  private static let bookmarkedWeatherInformationCollection = "/weather_information/bookmarked/"
  private static let nearbyWeatherInformationCollection = "/weather_information/nearby/"
  
  // MARK: - Initialization
  
  init() {}
}

// MARK: - Private Helpers

private extension WeatherInformationService2 {
  
  func updateBookmarkedWeatherInformation() {
    // dependency: bookmarked locations service
  }
  
  func updateNearbyWeatherInformation() {
    // dependency: location service
  }
}

// MARK: - WeatherInformationProvisioning

protocol WeatherInformationProvisioning {
  func createBookmarkedWeatherInformationListObservable() -> Observable<[PersistencyModel<WeatherInformationDTO>]>
  func createBookmarkedWeatherInformationObservable(for identifier: String) -> Observable<PersistencyModel<WeatherInformationDTO>?>
  func createNearbyWeatherInformationListObservable() -> Observable<[PersistencyModel<WeatherInformationDTO>]>
  func createNearbyWeatherInformationObservable(for identifier: String) -> Observable<PersistencyModel<WeatherInformationDTO>?>
}

extension WeatherInformationService2: WeatherInformationProvisioning {
  
  func createBookmarkedWeatherInformationListObservable() -> Observable<[PersistencyModel<WeatherInformationDTO>]> {
    persistencyWorker.observeResources(Self.bookmarkedWeatherInformationCollection, type: WeatherInformationDTO.self)
  }
  
  func createBookmarkedWeatherInformationObservable(for identifier: String) -> Observable<PersistencyModel<WeatherInformationDTO>?> {
    let identity = PersistencyModelIdentity(
      collection: Self.bookmarkedWeatherInformationCollection,
      identifier: identifier
    )
    return persistencyWorker.observeResource(identity, type: WeatherInformationDTO.self)
  }
  
  func createNearbyWeatherInformationListObservable() -> Observable<[PersistencyModel<WeatherInformationDTO>]> {
    persistencyWorker.observeResources(Self.bookmarkedWeatherInformationCollection, type: WeatherInformationDTO.self)
  }
  
  func createNearbyWeatherInformationObservable(for identifier: String) -> Observable<PersistencyModel<WeatherInformationDTO>?> {
    let identity = PersistencyModelIdentity(
      collection: Self.nearbyWeatherInformationCollection,
      identifier: identifier
    )
    return persistencyWorker.observeResource(identity, type: WeatherInformationDTO.self)
  }
}
