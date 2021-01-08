//
//  ApiKeyService2.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 07.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxAlamofire

// MARK: - Domain-Specific Errors

extension ApiKeyService2 {
  enum DomainError: String, Error {
    var domain: String { "WeatherInformationService" }
    
    case apiKeyMissingError = "Trying to request data from OpenWeatherMap, but no API key exists."
    case apiKeyInvalidError = "Trying to request data from OpenWeatherMap, but the API key is invalid."
  }
}

// MARK: - Domain-Specific Types

extension ApiKeyService2 {
  enum ApiKeyValidity {
    case valid(apiKey: String)
    case invalid
    case missing
    case unknown(apiKey: String)
  }
}

// MARK: - Persistency Keys
 
private extension ApiKeyService2 {
  enum PersistencyKeys {
    case userApiKey
    
    var collection: String {
      switch self {
      case .userApiKey: return "/api_keys/"
      }
    }
    
    var identifier: String {
      switch self {
      case .userApiKey: return "user_api_key"
      }
    }
  }
}

// MARK: - Class Definition

final class ApiKeyService2 {
  
  // MARK: - Assets
  
  private lazy var persistencyWorker: RealmPersistencyWorker = {
    try! RealmPersistencyWorker( // swiftlint:disable:this force_try
      storageLocation: .documents,
      dataBaseFileName: "ApiKeyServiceDataBase"
    )
  }()
}

// MARK: - API Key Validity

protocol ApiKeyValidity {
  func createApiKeyIsValidObservable() -> Observable<ApiKeyService2.ApiKeyValidity>
}

extension ApiKeyService2: ApiKeyValidity {
  
  func createApiKeyIsValidObservable() -> Observable<ApiKeyService2.ApiKeyValidity> {
    let identity = PersistencyModelIdentity(
      collection: PersistencyKeys.userApiKey.collection,
      identifier: PersistencyKeys.userApiKey.identifier
    )
    return persistencyWorker
      .observeResource(with: identity, type: ApiKeyDTO.self)
      .map { $0?.entity.apiKey }
      .flatMapLatest { apiKey -> Observable<ApiKeyService2.ApiKeyValidity> in
        guard let apiKey = apiKey else {
          return Observable.just(.missing)
        }
        return RxAlamofire
          .requestData(.get, Constants.Urls.kOpenWeatherMapApitTestRequestUrl(with: apiKey))
          .map { response -> ApiKeyService2.ApiKeyValidity in
            if response.0.statusCode == 401 {
              return .invalid
            }
            guard response.0.statusCode == 200 else {
              return .unknown(apiKey: apiKey) // another http error was returned and it cannot be determined whether the key is valid
            }
            return .valid(apiKey: apiKey)
          }
      }
  }
}

// MARK: - API Key Persistence

protocol ApiKeyPersistence: ApiKeySetting, ApiKeyReading {
  func createSetApiKeyCompletable(_ apiKey: String) -> Completable
  func createGetApiKeyObservable() -> Observable<String>
}

extension ApiKeyService2: ApiKeyPersistence {
  
  func createSetApiKeyCompletable(_ apiKey: String) -> Completable {
    Single
      .just(ApiKeyDTO(apiKey: apiKey))
      .map {
        PersistencyModel(identity: PersistencyModelIdentity(collection: PersistencyKeys.userApiKey.collection,
                                                            identifier: PersistencyKeys.userApiKey.identifier),
                         entity: $0)
      }
      .flatMapCompletable { [unowned persistencyWorker] in persistencyWorker.saveResource($0, type: ApiKeyDTO.self) }
  }
  
  func createGetApiKeyObservable() -> Observable<String> {
    createApiKeyIsValidObservable()
      .map { apiKeyValidity -> String in
        switch apiKeyValidity {
        case let .valid(apiKey):
          return apiKey
        case .invalid:
          throw ApiKeyService2.DomainError.apiKeyInvalidError
        case .missing:
          throw ApiKeyService2.DomainError.apiKeyMissingError
        case let .unknown(apiKey):
          return apiKey
        }
      }
  }
}

// MARK: - API Key Setting

protocol ApiKeySetting {
  func createSetApiKeyCompletable(_ apiKey: String) -> Completable
}

extension ApiKeyService2: ApiKeySetting {}

// MARK: - API Key Reading

protocol ApiKeyReading {
  func createGetApiKeyObservable() -> Observable<String>
}

extension ApiKeyService2: ApiKeyReading {}
