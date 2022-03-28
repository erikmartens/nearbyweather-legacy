//
//  ApplicationCycleService.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 28.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxAlamofire

// MARK: - Domain-Specific Errors

extension ApplicationCycleService {
  enum DomainError: Error {
    var domain: String { "ApplicationCycleService" }
  }
}

// MARK: - Domain-Specific Types

extension ApplicationCycleService {
  
}

// MARK: - Persistency Keys
 
private extension ApplicationCycleService {
  enum PersistencyKeys {
    case installVersion
    case setupCompleted
    case migrated_2_2_2_to_3_0_0 // swiftlint:disable:this identifier_name
    
    var collection: String {
      switch self {
      case .installVersion: return "/application_cycle/install_version/"
      case .setupCompleted: return "/application_cycle/setup_complete/"
      case .migrated_2_2_2_to_3_0_0: return "/application_cycle/migrated_2_2_2_to_3_0_0/"
      }
    }
    
    var identifier: String {
      switch self {
      case .installVersion: return "default"
      case .setupCompleted: return "default"
      case .migrated_2_2_2_to_3_0_0: return "default"
      }
    }
  }
}

// MARK: - Dependencies

extension ApplicationCycleService {
  struct Dependencies {
    let persistencyService: PersistencyProtocol
  }
}

// MARK: - Class Definition

final class ApplicationCycleService {
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }
}
extension ApplicationCycleService {
  
  func createSetInstallVersionCompletable(_ model: InstallVersionModel) -> Completable {
    Single
      .just(model)
      .map {
        PersistencyModel<InstallVersionModel>(
          identity: PersistencyModelIdentity(
            collection: PersistencyKeys.installVersion.collection,
            identifier: PersistencyKeys.installVersion.identifier
          ),
          entity: $0
        )
      }
      .flatMapCompletable { [dependencies] in dependencies.persistencyService.saveResource($0, type: InstallVersionModel.self) }
  }
  
  func createGetInstallVersionObservable() -> Observable<InstallVersionModel?> {
    dependencies
      .persistencyService
      .observeResource(
        with: PersistencyModelIdentity(
          collection: PersistencyKeys.installVersion.collection,
          identifier: PersistencyKeys.installVersion.identifier
        ),
        type: InstallVersionModel.self
      )
      .map { $0?.entity }
  }
  
  func createSetMigration_2_2_2_to_3_0_0_CompletedCompletable(_ model: MigrationCompletedModel) -> Completable {
    Single
      .just(model)
      .map {
        PersistencyModel<MigrationCompletedModel>(
          identity: PersistencyModelIdentity(
            collection: PersistencyKeys.migrated_2_2_2_to_3_0_0.collection,
            identifier: PersistencyKeys.migrated_2_2_2_to_3_0_0.identifier
          ),
          entity: $0
        )
      }
      .flatMapCompletable { [dependencies] in dependencies.persistencyService.saveResource($0, type: MigrationCompletedModel.self) }
  }
  
  func createGetMigration_2_2_2_to_3_0_0_CompletedObservable() -> Observable<MigrationCompletedModel?> {
    dependencies
      .persistencyService
      .observeResource(
        with: PersistencyModelIdentity(
          collection: PersistencyKeys.migrated_2_2_2_to_3_0_0.collection,
          identifier: PersistencyKeys.migrated_2_2_2_to_3_0_0.identifier
        ),
        type: MigrationCompletedModel.self
      )
      .map { $0?.entity }
  }
  
  func createSetSetupCompletedCompletable(_ model: SetupCompletedModel) -> Completable {
    Single
      .just(model)
      .map {
        PersistencyModel<SetupCompletedModel>(
          identity: PersistencyModelIdentity(
            collection: PersistencyKeys.setupCompleted.collection,
            identifier: PersistencyKeys.setupCompleted.identifier
          ),
          entity: $0
        )
      }
      .flatMapCompletable { [dependencies] in dependencies.persistencyService.saveResource($0, type: SetupCompletedModel.self) }
  }
  
  func createGetSetupCompletedObservable() -> Observable<SetupCompletedModel?> {
    dependencies
      .persistencyService
      .observeResource(
        with: PersistencyModelIdentity(
          collection: PersistencyKeys.setupCompleted.collection,
          identifier: PersistencyKeys.setupCompleted.identifier
        ),
        type: SetupCompletedModel.self
      )
      .map { $0?.entity }
  }
}

// MARK: - Application Migration

protocol ApplicationMigrationPersistence: ApplicationMigrationSetting, ApplicationMigrationReading {}
extension ApplicationCycleService: ApplicationMigrationPersistence {}

protocol ApplicationMigrationSetting {
  func createSetMigration_2_2_2_to_3_0_0_CompletedCompletable(_ model: MigrationCompletedModel) -> Completable
}

extension ApplicationCycleService: ApplicationMigrationSetting {}

protocol ApplicationMigrationReading {
  func createGetMigration_2_2_2_to_3_0_0_CompletedObservable() -> Observable<MigrationCompletedModel?>
}

extension ApplicationCycleService: ApplicationMigrationReading {}

// MARK: - Application State

protocol ApplicationStatePersistence: ApplicationStateSetting, ApplicationStateReading {}
extension ApplicationCycleService: ApplicationStatePersistence {}

protocol ApplicationStateSetting {
  func createSetSetupCompletedCompletable(_ model: SetupCompletedModel) -> Completable
}

extension ApplicationCycleService: ApplicationStateSetting {}

protocol ApplicationStateReading {
  func createGetSetupCompletedObservable() -> Observable<SetupCompletedModel?>
}

extension ApplicationCycleService: ApplicationStateReading {}
