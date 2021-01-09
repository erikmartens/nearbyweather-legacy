//
//  PersistenceService2.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 09.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxOptional
import RxAlamofire

// MARK: - Domain-Specific Errors

extension PersistencyService2 {
  enum DomainError: String, Error {
    var domain: String { "PersistencyService" }
    
    case someError = "" // TODO
  }
}

// MARK: - Persistency Keys

private extension PersistencyService2 {
  enum PersistencyKeys {
    
    var collection: String {
      switch self {
      }
    }
  }
}

// MARK: - Class Definition

final class PersistencyService2 {
  
  // MARK: - Assets
  
  private lazy var persistencyWorker: RealmPersistencyWorker = {
    try! RealmPersistencyWorker( // swiftlint:disable:this force_try
      storageLocation: .documents,
      dataBaseFileName: "NearbyWeather_UserData_DataBase"
    )
  }()
  
  private static let persistencyWriteScheduler = SerialDispatchQueueScheduler(
    internalSerialQueueName: "PersistencyService.PersistencyWriteScheduler"
  )
}

// MARK: - Weather Information Provisioning

protocol PersistencyProtocol {
  func saveResources<T: Codable>(_ resources: [PersistencyModel<T>], type: T.Type) -> Completable
  func saveResource<T: Codable>(_ resource: PersistencyModel<T>, type: T.Type) -> Completable
  func readResources<T: Codable>(in collection: String, type: T.Type) -> Single<[PersistencyModel<T>]>
  func readResource<T: Codable>(with identity: PersistencyModelIdentityProtocol, type: T.Type) -> Single<PersistencyModel<T>?>
  func observeResources<T: Codable>(in collection: String, type: T.Type) -> Observable<[PersistencyModel<T>]>
  func observeResource<T: Codable>(with identity: PersistencyModelIdentityProtocol, type: T.Type) -> Observable<PersistencyModel<T>?>
  func deleteResources(with identities: [PersistencyModelIdentityProtocol]) -> Completable
  func deleteResources(in collection: String) -> Completable
  func deleteResource(with identity: PersistencyModelIdentityProtocol) -> Completable
}

extension PersistencyService2: PersistencyProtocol {
  
  func saveResources<T: Codable>(_ resources: [PersistencyModel<T>], type: T.Type) -> Completable {
    persistencyWorker
      .saveResources(resources, type: T.self)
      .subscribeOn(Self.persistencyWriteScheduler)
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
  }
  
  func saveResource<T: Codable>(_ resource: PersistencyModel<T>, type: T.Type) -> Completable {
    persistencyWorker
      .saveResource(resource, type: T.self)
      .subscribeOn(Self.persistencyWriteScheduler)
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
  }
  
  func readResources<T: Codable>(in collection: String, type: T.Type) -> Single<[PersistencyModel<T>]> {
    persistencyWorker
      .readResources(in: collection, type: T.self)
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
  }
  
  func readResource<T: Codable>(with identity: PersistencyModelIdentityProtocol, type: T.Type) -> Single<PersistencyModel<T>?> {
    persistencyWorker
      .readResource(with: identity, type: T.self)
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
  }
  
  func observeResources<T: Codable>(in collection: String, type: T.Type) -> Observable<[PersistencyModel<T>]> {
    persistencyWorker
      .observeResources(in: collection, type: T.self)
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
  }
  
  func observeResource<T: Codable>(with identity: PersistencyModelIdentityProtocol, type: T.Type) -> Observable<PersistencyModel<T>?> {
    persistencyWorker
      .observeResource(with: identity, type: T.self)
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
  }
  
  func deleteResources(with identities: [PersistencyModelIdentityProtocol]) -> Completable {
    persistencyWorker
      .deleteResources(with: identities)
      .subscribeOn(Self.persistencyWriteScheduler)
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
  }
  
  func deleteResources(in collection: String) -> Completable {
    persistencyWorker
      .deleteResources(in: collection)
      .subscribeOn(Self.persistencyWriteScheduler)
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
  }
  
  func deleteResource(with identity: PersistencyModelIdentityProtocol) -> Completable {
    persistencyWorker
      .deleteResource(with: identity)
      .subscribeOn(Self.persistencyWriteScheduler)
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
  }
}
