//
//  WeatherInformationService2.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 29.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxAlamofire
import Alamofire

enum WeatherInformationServiceError: String, Error {
  
  var domain: String {
    "WeatherInformationService"
  }
  
  case apiKeyError = "Trying to request data from OpenWeatherMap, but no API key was found."
}


extension WeatherInformationService2 {
  struct Dependencies {
    let weatherStationService: WeatherStationService2
    let userLocationService: UserLocationService2
  }
}

final class WeatherInformationService2 {
  
  // MARK: - Assets
  
  private lazy var persistencyWorker: RealmPersistencyWorker = {
    try! RealmPersistencyWorker(
      storageLocation: .documents,
      dataBaseFileName: "WeatherInformationDataBase"
    )
  }()
  
  private static let persistencyWriteScheduler = SerialDispatchQueueScheduler(internalSerialQueueName: "WeatherInformationService.PersistencyWriteScheduler")
  
  private static let bookmarkedWeatherInformationCollection = "/weather_information/bookmarked/"
  private static let nearbyWeatherInformationCollection = "/weather_information/nearby/"
  
  private var apiKey: String? {
    UserDefaults.standard.value(forKey: Constants.Keys.UserDefaults.kNearbyWeatherApiKeyKey) as? String
  }
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  // MARK: - Initialization
  
  init(dependencies: WeatherInformationService2.Dependencies) {
    self.dependencies = dependencies
  }
}

// MARK: - Private Helpers

private extension WeatherInformationService2 {
  
  private static func mapResponseToPersistencyModel(_ response: (HTTPURLResponse, Data), identifier: Int) -> PersistencyModel<WeatherInformationDTO>? {
    guard response.0.statusCode == 200,
      let weatherInformationDto = try? JSONDecoder().decode(WeatherInformationDTO.self, from: response.1) else {
        return nil
    }
    return PersistencyModel(
      identity: PersistencyModelIdentity(
        collection: Self.bookmarkedWeatherInformationCollection,
        identifier: String(identifier)
      ),
      entity: weatherInformationDto
    )
  }
  
  func updateBookmarkedWeatherInformation() {
    _ = Observable
    .just([1, 2, 3]) // TODO // dependency: bookmarked locations service
    .flatMapLatest { [apiKey] identifiers -> Observable<[PersistencyModel<WeatherInformationDTO>]> in
      guard let apiKey = apiKey else {
        throw WeatherInformationServiceError.apiKeyError
      }
      return Observable.zip(
        identifiers.map { identifier -> Observable<PersistencyModel<WeatherInformationDTO>> in
          RxAlamofire
            .requestData(.get, Constants.Urls.kOpenWeatherMapSingleStationtDataRequestUrl(with: apiKey, stationIdentifier: identifier))
            .map { Self.mapResponseToPersistencyModel($0, identifier: identifier) }
            .compactMap { $0 }
        }
      )
    }
    .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
    .observeOn(Self.persistencyWriteScheduler)
    .take(1)
    .asSingle()
    .flatMapCompletable { [persistencyWorker] in persistencyWorker.saveResources($0, type: WeatherInformationDTO.self) }
    .subscribe()
  }
  
  func updateWeatherInformationForStation(with identifier: Int) {
    _ = Single
      .just(identifier)
      .flatMapCompletable { [apiKey, persistencyWorker] identifier -> Completable in
        guard let apiKey = apiKey else {
          throw WeatherInformationServiceError.apiKeyError
        }
        return RxAlamofire
          .requestData(.get, Constants.Urls.kOpenWeatherMapSingleStationtDataRequestUrl(with: apiKey, stationIdentifier: identifier))
          .map { Self.mapResponseToPersistencyModel($0, identifier: identifier) }
          .compactMap { $0 }
          .take(1)
          .asSingle()
          .flatMapCompletable { [persistencyWorker] in persistencyWorker.saveResource($0, type: WeatherInformationDTO.self) }
      }
      .subscribe()
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
    persistencyWorker.observeResources(in: Self.bookmarkedWeatherInformationCollection, type: WeatherInformationDTO.self)
  }
  
  func createBookmarkedWeatherInformationObservable(for identifier: String) -> Observable<PersistencyModel<WeatherInformationDTO>?> {
    let identity = PersistencyModelIdentity(
      collection: Self.bookmarkedWeatherInformationCollection,
      identifier: identifier
    )
    return persistencyWorker.observeResource(with: identity, type: WeatherInformationDTO.self)
  }
  
  func createNearbyWeatherInformationListObservable() -> Observable<[PersistencyModel<WeatherInformationDTO>]> {
    persistencyWorker.observeResources(in: Self.bookmarkedWeatherInformationCollection, type: WeatherInformationDTO.self)
  }
  
  func createNearbyWeatherInformationObservable(for identifier: String) -> Observable<PersistencyModel<WeatherInformationDTO>?> {
    let identity = PersistencyModelIdentity(
      collection: Self.nearbyWeatherInformationCollection,
      identifier: identifier
    )
    return persistencyWorker.observeResource(with: identity, type: WeatherInformationDTO.self)
  }
}
