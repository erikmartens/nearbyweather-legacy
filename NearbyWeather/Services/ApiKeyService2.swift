//
//  ApiKeyService2.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 07.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxOptional

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
    case valid
    case invalid
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

// MARK: - Dependencies

extension ApiKeyService2 {
  struct Dependencies {
    let preferencesService: PreferencesService2
  }
}

// MARK: - Class Definition

final class ApiKeyService2 {
  
  // MARK: - Assets
  
  private lazy var persistencyWorker: RealmPersistencyWorker = {
    try! RealmPersistencyWorker(
      storageLocation: .documents,
      dataBaseFileName: "ApiKeyServiceDataBase"
    )
  }()
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }
}

// MARK: - API Key Lookup

protocol ApiKeyLookup {
  func createApiKeyIsValidObservable() -> Observable<ApiKeyService2.ApiKeyValidity>
  func createSetApiKeyCompletable(_ apiKey: String) -> Completable
  func createGetApiKeyObservable() -> Observable<String?>
}

extension ApiKeyService2: ApiKeyLookup {
  
  func createApiKeyIsValidObservable() -> Observable<ApiKeyService2.ApiKeyValidity> {
    
  }
  
  func createSetApiKeyCompletable(_ apiKey: String) -> Completable {
    
  }
  
  func createGetApiKeyObservable() -> Observable<String?> {
    
  }
}
