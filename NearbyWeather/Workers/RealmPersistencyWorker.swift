//
//  RealmPersistencyWorker.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 21.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RealmSwift
import RxRealm
import RxSwift

protocol PersistencyModelProtocol {
  associatedtype T
  var identity: PersistencyModelIdentityProtocol { get }
  var entity: T { get }
}

struct PersistencyModel<T: Codable>: PersistencyModelProtocol {
  var identity: PersistencyModelIdentityProtocol
  var entity: T
  
  init?(collection: String, identifier: String, data: Data?) {
    self.identity = PersistencyModelIdentity(collection: collection, identifier: identifier)
    guard let data = data,
      let entity = try? JSONDecoder().decode(T.self, from: data) else {
        return nil
    }
    self.entity = entity
  }
  
  func toRealmModel() -> RealmModel {
    RealmModel(
      collection: identity.collection,
      identifier: identity.identifier,
      data: try? JSONEncoder().encode(entity)
    )
  }
}

protocol PersistencyModelIdentityProtocol {
  var collection: String { get }
  var identifier: String { get }
}

struct PersistencyModelIdentity: PersistencyModelIdentityProtocol {
  let collection: String
  let identifier: String
}

internal class RealmModel: Object {
  
  @objc dynamic public var collection: String = ""
  @objc dynamic public var identifier: String = ""
  @objc dynamic public var data: Data?
  
  internal convenience init(collection: String, identifier: String, data: Data?) {
    self.init()
    self.collection = collection
    self.identifier = identifier
    self.data = data
  }
  
  override public static func indexedProperties() -> [String] {
    ["collection", "identifier"]
  }
}

enum RealmPersistencyWorkerError: String, Error {
  
  var domain: String {
    "RealmPersistencyWorker"
  }
  
  case realmConfigurationError = "Trying to access Realm with configuration, but an error occured."
}

final class RealmPersistencyWorker {
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  private let baseDirectory: URL
  private let databaseFileName: String
  private let objectTypes: [Object.Type]?
  
  private lazy var configuration: Realm.Configuration = {
    Realm.Configuration(
      fileURL: databaseUrl,
      readOnly: false,
      migrationBlock: { (_, _) in },
      deleteRealmIfMigrationNeeded: false,
      objectTypes: objectTypes
    )
  }()
  
  private lazy var databaseUrl: URL = {
    baseDirectory.appendingPathComponent("\(databaseFileName).realm")
  }()
  
  private var realm: Realm? {
    try? Realm(configuration: configuration)
  }
  
  // MARK: - Initialization
  
  init(
    baseDirectoryUrl: URL,
    dataBaseFileName: String,
    objectTypes: [Object.Type]?
  ) {
    self.baseDirectory = baseDirectoryUrl
    self.databaseFileName = dataBaseFileName
    self.objectTypes = objectTypes
    
    createBaseDirectoryIfNeeded()
  }
}

// MARK: - Private Helper Functions

private extension RealmPersistencyWorker {
  
  private func createBaseDirectoryIfNeeded() {
    // basedirectoy (application support directory) may not exist yet -> has to be created first
    if !FileManager.default.fileExists(atPath: baseDirectory.path, isDirectory: nil) {
      do {
        try FileManager.default.createDirectory(atPath: baseDirectory.path, withIntermediateDirectories: true, attributes: nil)
      } catch {
        printDebugMessage(
          domain: String(describing: self),
          message: "Error while creating directory \(baseDirectory.path). Error-Description: \(error.localizedDescription)"
        )
        fatalError(error.localizedDescription)
      }
    }
  }
}

// MARK: - Public CRUD Functions

extension RealmPersistencyWorker {
  
  /// observes all resources within a specified collection
  func observeResources<T: Codable>(_ collection: String, classType: T.Type) -> Observable<[PersistencyModel<T>]> {
    Observable<Results<RealmModel>>
      .create { [configuration] handler in
        do {
          let realm = try Realm(configuration: configuration)
          let predicate = NSPredicate(format: "collection = %@", collection)
          let results = realm
            .objects(RealmModel.self)
            .filter(predicate)
          handler.onNext(results)
        } catch {
          handler.onError(error)
        }
        return Disposables.create()
    }
    .map { results -> [PersistencyModel<T>] in
      results.compactMap { PersistencyModel(collection: $0.collection, identifier: $0.identifier, data: $0.data) }
    }
  }
  
  /// observes a specified resource for a specified identity
  func observeResource<T: Codable>(_ identity: PersistencyModelIdentity, classType: T.Type) -> Observable<PersistencyModel<T>?> {
    Observable<Results<RealmModel>>
      .create { [configuration] handler in
        do {
          let realm = try Realm(configuration: configuration)
          let predicate = NSPredicate(format: "collection = %@ AND identifier = %@", identity.collection, identity.identifier)
          let results = realm
            .objects(RealmModel.self)
            .filter(predicate)
          handler.onNext(results)
        } catch {
          handler.onError(error)
        }
        return Disposables.create()
    }
    .map { results -> PersistencyModel<T>? in
      results
        .compactMap { PersistencyModel(collection: $0.collection, identifier: $0.identifier, data: $0.data) }
        .first
    }
  }
  
  
  /// save a new set of resources to the specified collection
  func createResources<T: RealmModel>(_ resources: [T], classType: T.Type) -> Completable {
    
  }
  
  /// save a new resource for its specified identity
  func createResource<T: RealmModel>(_ resource: T, classType: T.Type) -> Completable {
    
  }
  
  /// override a resource's content with updated
  func updateResources<T: RealmModel>(_ resources: [T], classType: T.Type) -> Completable {
    
  }
  
  func updateResource<T: RealmModel>(_ resource: T, classType: T.Type) -> Completable {
    
  }
  
  func deleteResources(with identities: [PersistencyModelIdentity]) -> Completable {
    Completable
      .create { [configuration] handler -> Disposable in
        do {
          let realm = try Realm(configuration: configuration)
          realm.beginWrite()
          identities.forEach { identity in
            let predicate = NSPredicate(format: "collection = %@ AND identifier = %@", identity.collection, identity.identifier)
            let identifiedObject = realm
              .objects(RealmModel.self)
              .filter(predicate)
            realm.delete(identifiedObject)
          }
          try realm.commitWrite()
          handler(.completed)
        } catch {
          handler(.error(error))
        }
        return Disposables.create()
    }
  }
  
  func deleteResource(with identity: PersistencyModelIdentity) -> Completable {
    Completable
      .create { [configuration] handler -> Disposable in
        do {
          let realm = try Realm(configuration: configuration)
          realm.beginWrite()
          
          let predicate = NSPredicate(format: "collection = %@ AND identifier = %@", identity.collection, identity.identifier)
          let identifiedObject = realm
            .objects(RealmModel.self)
            .filter(predicate)
          
          realm.delete(identifiedObject)
          try realm.commitWrite()
          
          handler(.completed)
        } catch {
          handler(.error(error))
        }
        return Disposables.create()
    }
  }
}
