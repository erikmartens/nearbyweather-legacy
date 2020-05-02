//
//  WeatherInformationService2.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 29.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxOptional
import RxAlamofire

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
    // TODO api key service
  }
}

final class WeatherInformationService2 {
  
  // MARK: - Assets
  
  private lazy var persistencyWorker: RealmPersistencyWorker = {
    try! RealmPersistencyWorker(
      storageLocation: .documents,
      dataBaseFileName: "WeatherInformationServiceDataBase"
    )
  }()
  
  private static let persistencyWriteScheduler = SerialDispatchQueueScheduler(
    internalSerialQueueName: "WeatherInformationService.PersistencyWriteScheduler"
  )
  
  private static let bookmarkedWeatherInformationCollection = "/weather_information/bookmarked/"
  private static let nearbyWeatherInformationCollection = "/weather_information/nearby/"
  
  private var apiKey: String? { // TODO: put into API service
    UserDefaults.standard.value(forKey: Constants.Keys.UserDefaults.kNearbyWeatherApiKeyKey) as? String
  }
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  // MARK: - Initialization
  
  init(dependencies: WeatherInformationService2.Dependencies) {
    self.dependencies = dependencies
  }
}

// MARK: - Weather Information Provisioning

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

// MARK: - Weather Information Updating

protocol WeatherInformationUpdating {
  func updateBookmarkedWeatherInformation()
  func updateWeatherInformationForBookmarkedStation(with identifier: Int)
  func updateNearbyWeatherInformation()
}

extension WeatherInformationService2: WeatherInformationUpdating {
  
  private static func mapSingleInformationResponseToPersistencyModel(_ response: (HTTPURLResponse, Data)) -> PersistencyModel<WeatherInformationDTO>? {
    guard response.0.statusCode == 200,
      let weatherInformationDto = try? JSONDecoder().decode(WeatherInformationDTO.self, from: response.1) else {
        return nil
    }
    return PersistencyModel(
      identity: PersistencyModelIdentity(
        collection: Self.bookmarkedWeatherInformationCollection,
        identifier: String(weatherInformationDto.cityID)
      ),
      entity: weatherInformationDto
    )
  }
  
  private static func mapMultiInformationResponseToPersistencyModel(_ response: (HTTPURLResponse, Data)) -> [PersistencyModel<WeatherInformationDTO>]? {
    guard response.0.statusCode == 200,
      let multiWeatherData = try? JSONDecoder().decode(WeatherInformationListDTO.self, from: response.1) else {
        return nil
    }
    
    return multiWeatherData.list.map { weatherInformationDto in
      PersistencyModel(
        identity: PersistencyModelIdentity(
          collection: Self.nearbyWeatherInformationCollection,
          identifier: String(weatherInformationDto.cityID)
        ),
        entity: weatherInformationDto
      )
    }
  }
  
  func updateBookmarkedWeatherInformation() {
    _ = dependencies.weatherStationService
      .createBookmarkedStationsObservable()
      .map { $0.map { $0.identifier } }
      .flatMapLatest { [apiKey] identifiers -> Observable<[PersistencyModel<WeatherInformationDTO>]> in
        guard let apiKey = apiKey else {
          throw WeatherInformationServiceError.apiKeyError
        }
        return Observable.zip(
          identifiers.map { identifier -> Observable<PersistencyModel<WeatherInformationDTO>> in
            RxAlamofire
              .requestData(.get, Constants.Urls.kOpenWeatherMapSingleStationtDataRequestUrl(with: apiKey, stationIdentifier: identifier))
              .map { Self.mapSingleInformationResponseToPersistencyModel($0) }
              .filterNil()
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
  
  func updateWeatherInformationForBookmarkedStation(with identifier: Int) {
    _ = Single
      .just(identifier)
      .map { [apiKey] identifier in
        guard let apiKey = apiKey else {
          throw WeatherInformationServiceError.apiKeyError
        }
        return Constants.Urls.kOpenWeatherMapSingleStationtDataRequestUrl(
          with: apiKey,
          stationIdentifier: identifier
        )
      }
      .flatMapCompletable { [persistencyWorker] url -> Completable in
        RxAlamofire
          .requestData(.get, url)
          .map { Self.mapSingleInformationResponseToPersistencyModel($0) }
          .filterNil()
          .take(1)
          .asSingle()
          .flatMapCompletable { [persistencyWorker] in persistencyWorker.saveResource($0, type: WeatherInformationDTO.self) }
      }
      .subscribe()
  }
  
  func updateNearbyWeatherInformation() {
    _ = dependencies.userLocationService
      .createDidUpdateLocationObservable()
      .map { [apiKey] location -> URL in
          guard let apiKey = apiKey else {
            throw WeatherInformationServiceError.apiKeyError
          }
          return Constants.Urls.kOpenWeatherMapMultiStationtDataRequestUrl(
            with: apiKey,
            currentLatitude: location.coordinate.latitude,
            currentLongitude: location.coordinate.longitude
          )
      }
      .flatMapLatest { url -> Observable<[PersistencyModel<WeatherInformationDTO>]> in
        RxAlamofire
          .requestData(.get, url)
          .map { Self.mapMultiInformationResponseToPersistencyModel($0) }
          .filterNil()
      }
      .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
      .observeOn(Self.persistencyWriteScheduler)
      .take(1)
      .asSingle()
      .flatMapCompletable { [persistencyWorker] in persistencyWorker.saveResources($0, type: WeatherInformationDTO.self) }
      .subscribe()
  }
}
