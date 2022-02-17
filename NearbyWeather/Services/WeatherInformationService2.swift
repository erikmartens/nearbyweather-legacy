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

// MARK: - Domain-Specific Errors

extension WeatherInformationService2 {
  enum DomainError: String, Error {
    var domain: String { "WeatherInformationService" }
    
    case nearbyWeatherInformationMissing = "Trying access the weather information data within the user's vicinity, but it does not exist."
    case bookmarkedWeatherInformationMissing = "Trying access the weather information data for the user's bookmarks, but it does not exist."
  }
}

// MARK: - Domain-Specific Types

extension WeatherInformationService2 {
  enum WeatherInformationAvailability {
    case available
    case unavailable
  }
}

// MARK: - Persistency Keys

private extension WeatherInformationService2 {
  enum PersistencyKeys {
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
    let persistencyService: PersistencyProtocol
    let preferencesService: WeatherListPreferenceReading
    let weatherStationService: WeatherStationBookmarkReading
    let userLocationService: UserLocationReading
    let apiKeyService: ApiKeyReading
  }
}

// MARK: - Class Definition

final class WeatherInformationService2 {
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }
}

// MARK: - Weather Information Provisioning

protocol WeatherInformationPersistence: WeatherInformationReading, WeatherInformationSetting {
  func createSetBookmarkedWeatherInformationListCompletable(_ list: [WeatherInformationDTO]) -> Completable
  func createDeleteBookmarkedWeatherInformationListCompletable() -> Completable
  func createGetBookmarkedWeatherInformationListObservable() -> Observable<[PersistencyModelThreadSafe<WeatherInformationDTO>]>
  func createGetBookmarkedWeatherInformationItemObservable(for identifier: String) -> Observable<PersistencyModelThreadSafe<WeatherInformationDTO>>
  func createSetNearbyWeatherInformationListCompletable(_ list: [WeatherInformationDTO]) -> Completable
  func createDeleteNearbyWeatherInformationListCompletable() -> Completable
  func createGetNearbyWeatherInformationListObservable() -> Observable<[PersistencyModelThreadSafe<WeatherInformationDTO>]>
  func createGetNearbyWeatherInformationObservable(for identifier: String) -> Observable<PersistencyModelThreadSafe<WeatherInformationDTO>>
  func createGetWeatherInformationItemObservable(for identifier: String, isBookmark: Bool) -> Observable<PersistencyModelThreadSafe<WeatherInformationDTO>>
}

extension WeatherInformationService2: WeatherInformationPersistence {
  
  func createSetBookmarkedWeatherInformationListCompletable(_ list: [WeatherInformationDTO]) -> Completable {
    Single
      .just(list)
      .map { list in
        list.map { weatherInformationDto in
          PersistencyModel(identity: PersistencyModelIdentity(collection: PersistencyKeys.bookmarkedWeatherInformation.collection,
                                                              identifier: String(weatherInformationDto.stationIdentifier)),
                           entity: weatherInformationDto)
        }
      }
      .flatMapCompletable { [dependencies] in dependencies.persistencyService.saveResources($0, type: WeatherInformationDTO.self) }
  }
  
  func createDeleteBookmarkedWeatherInformationListCompletable() -> Completable {
    Single
      .just(PersistencyKeys.bookmarkedWeatherInformation.collection)
      .flatMapCompletable { [dependencies] in dependencies.persistencyService.deleteResources(in: $0) }
  }
  
  func createGetBookmarkedWeatherInformationListObservable() -> Observable<[PersistencyModelThreadSafe<WeatherInformationDTO>]> {
    dependencies.persistencyService.observeResources(in: PersistencyKeys.bookmarkedWeatherInformation.collection, type: WeatherInformationDTO.self)
  }
  
  func createGetBookmarkedWeatherInformationItemObservable(for identifier: String) -> Observable<PersistencyModelThreadSafe<WeatherInformationDTO>> {
    let identity = PersistencyModelIdentity(
      collection: PersistencyKeys.bookmarkedWeatherInformation.collection,
      identifier: identifier
    )
    return dependencies
      .persistencyService
      .observeResource(with: identity, type: WeatherInformationDTO.self)
      .errorOnNil(DomainError.bookmarkedWeatherInformationMissing)
  }
  
  func createSetNearbyWeatherInformationListCompletable(_ list: [WeatherInformationDTO]) -> Completable {
    Single
      .just(list)
      .map { list in
        list.map { weatherInformationDto in
          PersistencyModel(identity: PersistencyModelIdentity(collection: PersistencyKeys.nearbyWeatherInformation.collection,
                                                              identifier: String(weatherInformationDto.stationIdentifier)),
                           entity: weatherInformationDto)
        }
      }
      .flatMapCompletable { [dependencies] in dependencies.persistencyService.saveResources($0, type: WeatherInformationDTO.self) }
  }
  
  func createDeleteNearbyWeatherInformationListCompletable() -> Completable {
    Single
      .just(PersistencyKeys.nearbyWeatherInformation.collection)
      .flatMapCompletable { [dependencies] in dependencies.persistencyService.deleteResources(in: $0) }
  }
  
  func createGetNearbyWeatherInformationListObservable() -> Observable<[PersistencyModelThreadSafe<WeatherInformationDTO>]> {
    dependencies.persistencyService.observeResources(in: PersistencyKeys.nearbyWeatherInformation.collection, type: WeatherInformationDTO.self)
  }
  
  func createGetNearbyWeatherInformationObservable(for identifier: String) -> Observable<PersistencyModelThreadSafe<WeatherInformationDTO>> {
    let identity = PersistencyModelIdentity(
      collection: PersistencyKeys.nearbyWeatherInformation.collection,
      identifier: identifier
    )
    return dependencies
      .persistencyService
      .observeResource(with: identity, type: WeatherInformationDTO.self)
      .errorOnNil(DomainError.nearbyWeatherInformationMissing)
  }
  
  func createGetWeatherInformationItemObservable(for identifier: String, isBookmark: Bool) -> Observable<PersistencyModelThreadSafe<WeatherInformationDTO>> {
    Observable
      .just(isBookmark)
      .flatMapLatest { [unowned self] isBookmark -> Observable<PersistencyModelThreadSafe<WeatherInformationDTO>> in
        isBookmark
          ? self.createGetBookmarkedWeatherInformationItemObservable(for: identifier)
          : self.createGetNearbyWeatherInformationObservable(for: identifier)
      }
  }
}

// MARK: - Weather Information Setting

protocol WeatherInformationSetting {
  func createSetBookmarkedWeatherInformationListCompletable(_ list: [WeatherInformationDTO]) -> Completable
  func createDeleteBookmarkedWeatherInformationListCompletable() -> Completable
  func createSetNearbyWeatherInformationListCompletable(_ list: [WeatherInformationDTO]) -> Completable
  func createDeleteNearbyWeatherInformationListCompletable() -> Completable
}

extension WeatherInformationService2: WeatherInformationSetting {}

// MARK: - Weather Information Reading

protocol WeatherInformationReading {
  func createGetBookmarkedWeatherInformationListObservable() -> Observable<[PersistencyModelThreadSafe<WeatherInformationDTO>]>
  func createGetBookmarkedWeatherInformationItemObservable(for identifier: String) -> Observable<PersistencyModelThreadSafe<WeatherInformationDTO>>
  func createGetNearbyWeatherInformationListObservable() -> Observable<[PersistencyModelThreadSafe<WeatherInformationDTO>]>
  func createGetNearbyWeatherInformationObservable(for identifier: String) -> Observable<PersistencyModelThreadSafe<WeatherInformationDTO>>
  func createGetWeatherInformationItemObservable(for identifier: String, isBookmark: Bool) -> Observable<PersistencyModelThreadSafe<WeatherInformationDTO>>
}

extension WeatherInformationService2: WeatherInformationReading {}

// MARK: - Weather Information Updating

protocol WeatherInformationUpdating {
  func createDidUpdateWeatherInformationObservable() -> Observable<WeatherInformationService2.WeatherInformationAvailability>
  func createUpdateBookmarkedWeatherInformationCompletable() -> Completable
  func createUpdateBookmarkedWeatherInformationCompletable(forStationWith identifier: Int) -> Completable
  func createUpdateNearbyWeatherInformationCompletable() -> Completable
}

extension WeatherInformationService2: WeatherInformationUpdating {
  
  func createDidUpdateWeatherInformationObservable() -> Observable<WeatherInformationAvailability> {
    Observable<WeatherInformationAvailability>
      .combineLatest(
        createGetBookmarkedWeatherInformationListObservable().map { $0.isEmpty },
        createGetNearbyWeatherInformationListObservable().map { $0.isEmpty },
        resultSelector: { ($0 && $1) ? .unavailable : .available }
      )
  }
  
  func createUpdateBookmarkedWeatherInformationCompletable() -> Completable {
    Observable
      .combineLatest(
        dependencies.apiKeyService.createGetApiKeyObservable(),
        dependencies.weatherStationService.createGetBookmarkedStationsObservable().map { $0.map { $0.identifier } },
        resultSelector: { apiKey, identifiers -> [URL] in
          identifiers.map { Constants.Urls.kOpenWeatherMapSingleStationtDataRequestUrl(with: apiKey, stationIdentifier: $0) }
        }
      )
      .flatMapLatest { urls -> Observable<[PersistencyModel<WeatherInformationDTO>]> in
        guard !urls.isEmpty else {
          return Observable.just([])
        }
        return Observable.zip(
          urls.map { url -> Observable<PersistencyModel<WeatherInformationDTO>> in
            RxAlamofire
              .requestData(.get, url)
              .map { Self.mapSingleInformationResponseToPersistencyModel($0) }
              .filterNil()
          }
        )
      }
      .take(1)
      .asSingle()
      .flatMapCompletable { [dependencies] in dependencies.persistencyService.saveResources($0, type: WeatherInformationDTO.self) }
  }
  
  func createUpdateBookmarkedWeatherInformationCompletable(forStationWith identifier: Int) -> Completable {
    Observable
      .combineLatest(
        dependencies.apiKeyService.createGetApiKeyObservable(),
        Observable.just(identifier),
        resultSelector: { apiKey, identifier -> URL in Constants.Urls.kOpenWeatherMapSingleStationtDataRequestUrl(with: apiKey, stationIdentifier: identifier) }
      )
      .asSingle()
      .flatMapCompletable { [dependencies] url -> Completable in
        RxAlamofire
          .requestData(.get, url)
          .map { Self.mapSingleInformationResponseToPersistencyModel($0) }
          .filterNil()
          .take(1)
          .asSingle()
          .flatMapCompletable { [dependencies] in dependencies.persistencyService.saveResource($0, type: WeatherInformationDTO.self) }
      }
  }
  
  func createUpdateNearbyWeatherInformationCompletable() -> Completable {
    Observable
      .combineLatest(
        dependencies.apiKeyService.createGetApiKeyObservable(),
        dependencies.userLocationService.createGetCurrentLocationObservable(),
        dependencies.preferencesService.createGetAmountOfNearbyResultsOptionObservable(),
        resultSelector: { apiKey, location, amountOfResultsOption -> URL in
          Constants.Urls.kOpenWeatherMapMultiStationtDataRequestUrl(
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
      .take(1)
      .asSingle()
      .flatMapCompletable { [dependencies] in dependencies.persistencyService.saveResources($0, type: WeatherInformationDTO.self) }
  }
}

// MARK: - Weather Information Migration

protocol WeatherInformationMigration {
  func createSetBookmarkedWeatherInformationListCompletable(_ list: [WeatherInformationDTO]) -> Completable
  func createSetNearbyWeatherInformationListCompletable(_ list: [WeatherInformationDTO]) -> Completable
}

extension WeatherInformationService2: WeatherInformationMigration {}

// MARK: - Helpers

private extension WeatherInformationService2 {
  
  static func mapSingleInformationResponseToPersistencyModel(_ response: (HTTPURLResponse, Data)) -> PersistencyModel<WeatherInformationDTO>? {
    guard response.0.statusCode == 200,
      let weatherInformationDto = try? JSONDecoder().decode(WeatherInformationDTO.self, from: response.1) else {
        return nil
    }
    return PersistencyModel(
      identity: PersistencyModelIdentity(
        collection: PersistencyKeys.bookmarkedWeatherInformation.collection,
        identifier: String(weatherInformationDto.stationIdentifier)
      ),
      entity: weatherInformationDto
    )
  }
  
  static func mapMultiInformationResponseToPersistencyModel(_ response: (HTTPURLResponse, Data)) -> [PersistencyModel<WeatherInformationDTO>]? {
    guard response.0.statusCode == 200,
      let multiWeatherData = try? JSONDecoder().decode(WeatherInformationListDTO.self, from: response.1) else {
        return nil
    }
    
    return multiWeatherData.list.map { weatherInformationDto in
      PersistencyModel(
        identity: PersistencyModelIdentity(
          collection: PersistencyKeys.nearbyWeatherInformation.collection,
          identifier: String(weatherInformationDto.stationIdentifier)
        ),
        entity: weatherInformationDto
      )
    }
  }
}
