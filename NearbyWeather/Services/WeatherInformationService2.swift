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

// MARK: - Domain-Specific Types

extension WeatherInformationService2 {
  enum WeatherInformationAvailability {
    case available
    case unavailable
  }
}

// MARK: - Persistency Keys

private extension WeatherInformationService2 {enum PersistencyKeys {
    case bookmarkedWeatherInformation
    case nearbyWeatherInformation
    
    var collection: String {
      switch self {
      case .bookmarkedWeatherInformation: return "/weather_information/bookmarked/"
      case .nearbyWeatherInformation: return "/weather_information/nearby/"
      }
    }
  }
}

// MARK: - Dependencies

extension WeatherInformationService2 {
  struct Dependencies {
    let preferencesService: PreferencesService2
    let userLocationService: UserLocationService2
    let apiKeyService: ApiKeyService2
  }
}

// MARK: - Class Definition

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
  
  private var apiKey: String? { // TODO: put into API service
    UserDefaults.standard.value(forKey: Constants.Keys.UserDefaults.kNearbyWeatherApiKeyKey) as? String
  }
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }
}

// MARK: - Weather Information Provisioning

protocol WeatherInformationProvisioning {
  func setBookmarkerWeatherInformationList(_ list: [WeatherInformationDTO]) -> Completable
  func createBookmarkedWeatherInformationListObservable() -> Observable<[PersistencyModel<WeatherInformationDTO>]>
  func createBookmarkedWeatherInformationObservable(for identifier: String) -> Observable<PersistencyModel<WeatherInformationDTO>?>
  func setNearbyWeatherInformationList(_ list: [WeatherInformationDTO]) -> Completable
  func createNearbyWeatherInformationListObservable() -> Observable<[PersistencyModel<WeatherInformationDTO>]>
  func createNearbyWeatherInformationObservable(for identifier: String) -> Observable<PersistencyModel<WeatherInformationDTO>?>
}

extension WeatherInformationService2: WeatherInformationProvisioning {
  
  func setBookmarkerWeatherInformationList(_ list: [WeatherInformationDTO]) -> Completable {
    Single
      .just(list)
      .map { list in
        list.map { weatherInformationDto in
          PersistencyModel(identity: PersistencyModelIdentity(collection: PersistencyKeys.bookmarkedWeatherInformation.collection,
                                                              identifier: String(weatherInformationDto.cityID)),
                           entity: weatherInformationDto)
        }
      }
      .flatMapCompletable { [unowned persistencyWorker] in persistencyWorker.saveResources($0, type: WeatherInformationDTO.self) }
  }
  
  func createBookmarkedWeatherInformationListObservable() -> Observable<[PersistencyModel<WeatherInformationDTO>]> {
    persistencyWorker.observeResources(in: PersistencyKeys.bookmarkedWeatherInformation.collection, type: WeatherInformationDTO.self)
  }
  
  func createBookmarkedWeatherInformationObservable(for identifier: String) -> Observable<PersistencyModel<WeatherInformationDTO>?> {
    let identity = PersistencyModelIdentity(
      collection: PersistencyKeys.bookmarkedWeatherInformation.collection,
      identifier: identifier
    )
    return persistencyWorker.observeResource(with: identity, type: WeatherInformationDTO.self)
  }
  
  func setNearbyWeatherInformationList(_ list: [WeatherInformationDTO]) -> Completable {
    Single
      .just(list)
      .map { list in
        list.map { weatherInformationDto in
          PersistencyModel(identity: PersistencyModelIdentity(collection: PersistencyKeys.nearbyWeatherInformation.collection,
                                                              identifier: String(weatherInformationDto.cityID)),
                           entity: weatherInformationDto)
        }
      }
      .flatMapCompletable { [unowned persistencyWorker] in persistencyWorker.saveResources($0, type: WeatherInformationDTO.self) }
  }
  
  func createNearbyWeatherInformationListObservable() -> Observable<[PersistencyModel<WeatherInformationDTO>]> {
    persistencyWorker.observeResources(in: PersistencyKeys.bookmarkedWeatherInformation.collection, type: WeatherInformationDTO.self)
  }
  
  func createNearbyWeatherInformationObservable(for identifier: String) -> Observable<PersistencyModel<WeatherInformationDTO>?> {
    let identity = PersistencyModelIdentity(
      collection: PersistencyKeys.nearbyWeatherInformation.collection,
      identifier: identifier
    )
    return persistencyWorker.observeResource(with: identity, type: WeatherInformationDTO.self)
  }
}

// MARK: - Weather Information Updating

protocol WeatherInformationUpdating {
  func createDidUpdateWeatherInformationObservable() -> Observable<WeatherInformationService2.WeatherInformationAvailability>
  func createUpdateBookmarkedWeatherInformationCompletable() -> Completable
  func createBookmarkedUpdateWeatherInformationCompletable(forStationWith identifier: Int) -> Completable
  func createUpdateNearbyWeatherInformationCompletable() -> Completable
}

extension WeatherInformationService2: WeatherInformationUpdating {
  
  private static func mapSingleInformationResponseToPersistencyModel(_ response: (HTTPURLResponse, Data)) -> PersistencyModel<WeatherInformationDTO>? {
    guard response.0.statusCode == 200,
      let weatherInformationDto = try? JSONDecoder().decode(WeatherInformationDTO.self, from: response.1) else {
        return nil
    }
    return PersistencyModel(
      identity: PersistencyModelIdentity(
        collection: PersistencyKeys.bookmarkedWeatherInformation.collection,
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
          collection: PersistencyKeys.nearbyWeatherInformation.collection,
          identifier: String(weatherInformationDto.cityID)
        ),
        entity: weatherInformationDto
      )
    }
  }
  
  func createDidUpdateWeatherInformationObservable() -> Observable<WeatherInformationAvailability> {
    Observable<WeatherInformationAvailability>
      .combineLatest(
        createBookmarkedWeatherInformationListObservable().map { $0.isEmpty },
        createNearbyWeatherInformationListObservable().map { $0.isEmpty },
        resultSelector: { ($0 && $1) ? .unavailable : .available }
      )
  }
  
  func createUpdateBookmarkedWeatherInformationCompletable() -> Completable {
    dependencies.preferencesService
      .createBookmarkedStationsObservable()
      .map { $0.map { $0.identifier } }
      .map { [apiKey] identifiers -> [URL] in
        guard let apiKey = apiKey else {
          throw ApiKeyService2.DomainError.apiKeyMissingError
        }
        return identifiers.map { Constants.Urls.kOpenWeatherMapSingleStationtDataRequestUrl(with: apiKey, stationIdentifier: $0) }
      }
      .flatMapLatest { urls -> Observable<[PersistencyModel<WeatherInformationDTO>]> in
        Observable.zip(
          urls.map { url -> Observable<PersistencyModel<WeatherInformationDTO>> in
            RxAlamofire
              .requestData(.get, url)
              .map { Self.mapSingleInformationResponseToPersistencyModel($0) }
              .filterNil()
          }
        )
      }
      .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
      .observeOn(Self.persistencyWriteScheduler)
      .take(1)
      .asSingle()
      .flatMapCompletable { [unowned persistencyWorker] in persistencyWorker.saveResources($0, type: WeatherInformationDTO.self) }
  }
  
  func createBookmarkedUpdateWeatherInformationCompletable(forStationWith identifier: Int) -> Completable {
    Single
      .just(identifier)
      .map { [apiKey] identifier in
        guard let apiKey = apiKey else {
          throw ApiKeyService2.DomainError.apiKeyMissingError
        }
        return Constants.Urls.kOpenWeatherMapSingleStationtDataRequestUrl(
          with: apiKey,
          stationIdentifier: identifier
        )
      }
      .flatMapCompletable { [unowned persistencyWorker] url -> Completable in
        RxAlamofire
          .requestData(.get, url)
          .map { Self.mapSingleInformationResponseToPersistencyModel($0) }
          .filterNil()
          .take(1)
          .asSingle()
          .flatMapCompletable { [unowned persistencyWorker] in persistencyWorker.saveResource($0, type: WeatherInformationDTO.self) }
      }
  }
  
  func createUpdateNearbyWeatherInformationCompletable() -> Completable {
    Observable
      .combineLatest(
        dependencies.userLocationService.createDidUpdateLocationObservable(),
        dependencies.preferencesService.createAmountOfNearbyResultsOptionObservable(),
        resultSelector: { [apiKey] location, amountOfResultsOption -> URL in
          guard let apiKey = apiKey else {
            throw ApiKeyService2.DomainError.apiKeyMissingError
          }
          return Constants.Urls.kOpenWeatherMapMultiStationtDataRequestUrl(
            with: apiKey,
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            numberOfResults: amountOfResultsOption.value.rawValue
          )
      })
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
      .flatMapCompletable { [unowned persistencyWorker] in persistencyWorker.saveResources($0, type: WeatherInformationDTO.self) }
  }
}
