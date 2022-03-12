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

extension ApiKeyService {
  enum DomainError: Error {
    var domain: String { "WeatherInformationService" }
    
    case apiKeyMissingError
    case apiKeyInvalidError(invalidApiKey: String)
    
    var rawValue: String {
      switch self {
      case .apiKeyMissingError: return "Trying to request data from OpenWeatherMap, but no API key exists."
      case let .apiKeyInvalidError(invalidApiKey): return "Trying to request data from OpenWeatherMap, but the API key is invalid: \(invalidApiKey)."
      }
    }
  }
}

// MARK: - Domain-Specific Types

extension ApiKeyService {
  enum ApiKeyValidity {
    case valid(apiKey: String)
    case invalid(invalidApiKey: String)
    case missing
    case unknown(apiKey: String)
    
    var isValid: Bool {
      switch self {
      case .valid:
        return true
      case .invalid, .missing, .unknown:
        return false
      }
    }
  }
}

extension ApiKeyService.ApiKeyValidity: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (let .valid(lhsVal), let .valid(rhsVal)):
      return lhsVal == rhsVal
    case (let .unknown(lhsVal), let .unknown(rhsVal)):
      return lhsVal == rhsVal
    case (.invalid, .invalid):
      return true
    case (.missing, .missing):
      return true
    default:
      return false
    }
  }
}

// MARK: - Persistency Keys
 
private extension ApiKeyService {
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

// MARK: - Dependencies

extension ApiKeyService {
  struct Dependencies {
    let persistencyService: PersistencyProtocol
  }
}

// MARK: - Class Definition

final class ApiKeyService {
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }
}

// MARK: - API Key Validity

protocol ApiKeyValidity {
  func createApiKeyIsValidObservable() -> Observable<ApiKeyService.ApiKeyValidity>
}

extension ApiKeyService: ApiKeyValidity {
  
  func createApiKeyIsValidObservable() -> Observable<ApiKeyService.ApiKeyValidity> {
    let identity = PersistencyModelIdentity(
      collection: PersistencyKeys.userApiKey.collection,
      identifier: PersistencyKeys.userApiKey.identifier
    )
    return dependencies
      .persistencyService
      .observeResource(with: identity, type: ApiKeyDTO.self)
      .map { $0?.entity.apiKey }
      .flatMapLatest { apiKey -> Observable<ApiKeyService.ApiKeyValidity> in
        guard let apiKey = apiKey else {
          return Observable.just(.missing)
        }
        return RxAlamofire
          .requestData(.get, Constants.Urls.kOpenWeatherMapApitTestRequestUrl(with: apiKey))
          .map { response -> ApiKeyService.ApiKeyValidity in
            if response.0.statusCode == 401 {
              return .invalid(invalidApiKey: apiKey)
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

extension ApiKeyService: ApiKeyPersistence {
  
  func createSetApiKeyCompletable(_ apiKey: String) -> Completable {
    Single
      .just(ApiKeyDTO(apiKey: apiKey))
      .map {
        PersistencyModel(identity: PersistencyModelIdentity(collection: PersistencyKeys.userApiKey.collection,
                                                            identifier: PersistencyKeys.userApiKey.identifier),
                         entity: $0)
      }
      .flatMapCompletable { [dependencies] in dependencies.persistencyService.saveResource($0, type: ApiKeyDTO.self) }
  }
  
  func createGetApiKeyObservable() -> Observable<String> {
    createApiKeyIsValidObservable()
      .map { apiKeyValidity -> String in
        switch apiKeyValidity {
        case let .valid(apiKey):
          return apiKey
        case let .invalid(invalidApiKey):
          throw ApiKeyService.DomainError.apiKeyInvalidError(invalidApiKey: invalidApiKey)
        case .missing:
          throw ApiKeyService.DomainError.apiKeyMissingError
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

extension ApiKeyService: ApiKeySetting {}

// MARK: - API Key Reading

protocol ApiKeyReading {
  func createGetApiKeyObservable() -> Observable<String>
  func createApiKeyIsValidObservable() -> Observable<ApiKeyService.ApiKeyValidity>
}

extension ApiKeyService: ApiKeyReading {}
