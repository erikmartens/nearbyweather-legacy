//
//  MigrationService.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxOptional

extension MigrationService {
  struct Dependencies {
    let preferencesService: PreferenceMigration
    let weatherInformationService: WeatherInformationMigration
    let weatherStationService: WeatherStationBookmarkMigration
    let apiKeyService: ApiKeySetting
  }
}

final class MigrationService { // TODO: move all Constants-Keys and DTOs (that are only needed here) to here and make private, after old services were deleted
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  // MARK: - Initialization
  
  init(dependencies: MigrationService.Dependencies) {
    self.dependencies = dependencies
  }
}

// MARK: - Functions

extension MigrationService {
  
  func runMigrationIfNeeded() {
    guard UserDefaults.standard.value(forKey: Constants.Keys.UserDefaults.kMigratedToVersion230) == nil else {
      return
    }
    
    // mirgrate api key
    let migrateApiKeyCompletable = Observable<String?>
      .create { handler in
        let apiKey = UserDefaults.standard.value(forKey: Constants.Keys.UserDefaults.kNearbyWeatherApiKeyKey) as? String
        handler.on(.next(apiKey))
        return Disposables.create()
      }
      .take(1)
      .asSingle()
      .flatMapCompletable { [dependencies] apiKey -> Completable in
        guard let apiKey = apiKey else {
          // previous data does not exist or could not be read -> do not try to migrate any further
          return Completable.create { handler in
            handler(.completed)
            return Disposables.create()
          }
        }
        return dependencies.apiKeyService.createSetApiKeyCompletable(apiKey)
      }
    
    // migrate preferences
    let migratePreferencesCompletable = Observable<PreferencesManagerStoredContentsWrapper?>
      .create { handler in
        let preferencesStoredContentsWrapper = try? JsonPersistencyWorker().retrieveJsonFromFile(
          with: Constants.Keys.Storage.kPreferencesManagerStoredContentsFileName,
          andDecodeAsType: PreferencesManagerStoredContentsWrapper.self,
          fromStorageLocation: .applicationSupport
        )
        handler.on(.next(preferencesStoredContentsWrapper))
        return Disposables.create()
      }
      .take(1)
      .asSingle()
      .flatMapCompletable { [dependencies] preferencesStoredContentsWrapper -> Completable in
        guard let preferencesStoredContentsWrapper = preferencesStoredContentsWrapper else {
          // previous data does not exist or could not be read -> do not try to migrate any further
          return Completable.create { handler in
            handler(.completed)
            return Disposables.create()
          }
        }
        return Completable.zip([
          dependencies.weatherStationService.createSetPreferredBookmarkCompletable(preferencesStoredContentsWrapper.preferredBookmark),
          dependencies.preferencesService.createSetAmountOfNearbyResultsOptionCompletable(preferencesStoredContentsWrapper.amountOfResults),
          dependencies.preferencesService.createSetTemperatureUnitOptionCompletable(preferencesStoredContentsWrapper.temperatureUnit),
          dependencies.preferencesService.createSetDimensionalUnitsOptionCompletable(preferencesStoredContentsWrapper.windspeedUnit),
          dependencies.preferencesService.createSetSortingOrientationOptionCompletable(preferencesStoredContentsWrapper.sortingOrientation)
        ])
      }
    
    // migrate weather information
    let migrateWeatherInformationCompletable = Observable<WeatherDataManagerStoredContentsWrapper?>
      .create { handler in
        let weatherInformationStoredContents = try? JsonPersistencyWorker().retrieveJsonFromFile(
          with: Constants.Keys.Storage.kWeatherDataManagerStoredContentsFileName,
          andDecodeAsType: WeatherDataManagerStoredContentsWrapper.self,
          fromStorageLocation: .documents
        )
        handler.on(.next(weatherInformationStoredContents))
        return Disposables.create()
      }
      .take(1)
      .asSingle()
      .flatMapCompletable { [dependencies] weatherInformationStoredContents -> Completable in
        guard let weatherInformationStoredContents = weatherInformationStoredContents else {
          // previous data does not exist or could not be read -> do not try to migrate anymore
          return Completable.create { handler in
            handler(.completed)
            return Disposables.create()
          }
        }
        return Completable.zip([
          dependencies.weatherInformationService.createSetBookmarkedWeatherInformationListCompletable(
            weatherInformationStoredContents.bookmarkedWeatherDataObjects?.compactMap { $0.weatherInformationDTO } ?? []
          ),
          dependencies.weatherInformationService.createSetNearbyWeatherInformationListCompletable(
            weatherInformationStoredContents.nearbyWeatherDataObject?.weatherInformationDTOs ?? []
          ),
          dependencies.weatherStationService.createSetBookmarkedStationsCompletable(
            weatherInformationStoredContents.bookmarkedLocations
          ),
          dependencies.weatherStationService.createSetBookmarksSortingCompletable(
            weatherInformationStoredContents.bookmarkedLocations.reduce([Int: Int]()) { partialResult, nextValue -> [Int: Int] in
              var mutablePartialResult = partialResult
              mutablePartialResult[nextValue.identifier] = mutablePartialResult.count
              return mutablePartialResult
            }
          )
        ])
      }
    
    // execute migration
    _ = Completable
      .zip([
        migrateApiKeyCompletable,
        migratePreferencesCompletable,
        migrateWeatherInformationCompletable
      ])
      .subscribe(onCompleted: { UserDefaults.standard.set(true, forKey: Constants.Keys.UserDefaults.kMigratedToVersion230) })
    
    // TODO: on success delete all old files
  }
}
