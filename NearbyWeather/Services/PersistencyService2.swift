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
  func readResources<T: Codable>(in collection: String, type: T.Type) -> Single<[PersistencyModelThreadSafe<T>]>
  func readResource<T: Codable>(with identity: PersistencyModelIdentityProtocol, type: T.Type) -> Single<PersistencyModelThreadSafe<T>?>
  func observeResources<T: Codable>(in collection: String, type: T.Type) -> Observable<[PersistencyModelThreadSafe<T>]>
  func observeResource<T: Codable>(with identity: PersistencyModelIdentityProtocol, type: T.Type) -> Observable<PersistencyModelThreadSafe<T>?>
  func deleteResources(with identities: [PersistencyModelIdentityProtocol]) -> Completable
  func deleteResources(in collection: String) -> Completable
  func deleteResource(with identity: PersistencyModelIdentityProtocol) -> Completable
}

extension PersistencyService2: PersistencyProtocol {
  
  func saveResources<T: Codable>(_ resources: [PersistencyModel<T>], type: T.Type) -> Completable {
    persistencyWorker
      .saveResources(resources, type: T.self)
      .subscribe(on: Self.persistencyWriteScheduler)
      .observe(on: ConcurrentDispatchQueueScheduler(qos: .default))
  }
  
  func saveResource<T: Codable>(_ resource: PersistencyModel<T>, type: T.Type) -> Completable {
    persistencyWorker
      .saveResource(resource, type: T.self)
      .subscribe(on: Self.persistencyWriteScheduler)
      .observe(on: ConcurrentDispatchQueueScheduler(qos: .default))
  }
  
  func readResources<T: Codable>(in collection: String, type: T.Type) -> Single<[PersistencyModelThreadSafe<T>]> {
    persistencyWorker
      .readResources(in: collection, type: T.self)
      .observe(on: ConcurrentDispatchQueueScheduler(qos: .default))
  }
  
  func readResource<T: Codable>(with identity: PersistencyModelIdentityProtocol, type: T.Type) -> Single<PersistencyModelThreadSafe<T>?> {
    persistencyWorker
      .readResource(with: identity, type: T.self)
      .observe(on: ConcurrentDispatchQueueScheduler(qos: .default))
  }
  
  func observeResources<T: Codable>(in collection: String, type: T.Type) -> Observable<[PersistencyModelThreadSafe<T>]> {
    persistencyWorker
      .observeResources(in: collection, type: T.self)
      .observe(on: ConcurrentDispatchQueueScheduler(qos: .default))
  }
  
  func observeResource<T: Codable>(with identity: PersistencyModelIdentityProtocol, type: T.Type) -> Observable<PersistencyModelThreadSafe<T>?> {
    persistencyWorker
      .observeResource(with: identity, type: T.self)
      .observe(on: ConcurrentDispatchQueueScheduler(qos: .default))
  }
  
  func deleteResources(with identities: [PersistencyModelIdentityProtocol]) -> Completable {
    persistencyWorker
      .deleteResources(with: identities)
      .subscribe(on: Self.persistencyWriteScheduler)
      .observe(on: ConcurrentDispatchQueueScheduler(qos: .default))
  }
  
  func deleteResources(in collection: String) -> Completable {
    persistencyWorker
      .deleteResources(in: collection)
      .subscribe(on: Self.persistencyWriteScheduler)
      .observe(on: ConcurrentDispatchQueueScheduler(qos: .default))
  }
  
  func deleteResource(with identity: PersistencyModelIdentityProtocol) -> Completable {
    persistencyWorker
      .deleteResource(with: identity)
      .subscribe(on: Self.persistencyWriteScheduler)
      .observe(on: ConcurrentDispatchQueueScheduler(qos: .default))
  }
}
