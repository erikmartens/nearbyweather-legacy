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
    let migrationIsRunningSubject: BehaviorSubject<Bool>
    let preferencesService: PreferenceMigration
    let weatherInformationService: WeatherInformationMigration
    let weatherStationService: WeatherStationBookmarkMigration
    let apiKeyService: ApiKeySetting
    let notificationService: NotificationPreferencesSetting
    let applicationCycleService: ApplicationMigrationSetting & ApplicationMigrationReading & ApplicationStateSetting
  }
}

final class MigrationService {
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  // MARK: - Initialization
  
  init(dependencies: MigrationService.Dependencies) {
    self.dependencies = dependencies
  }
}

// MARK: - Functions

extension MigrationService {
  
  func createRun_2_2_1_to_3_0_0_migrationCompletable() -> Completable {
    dependencies.applicationCycleService
      .createGetMigration_2_2_1_to_3_0_0_CompletedObservable()
      .take(1)
      .asSingle()
      .flatMapCompletable { [dependencies] migrationCompletedModel in
        // users who have ACTIVELY used version 2.2.1 will have stored an API Key
        // users who have not done so, will not suffer from skipping the migration
        // migrationCompletedModel == nil && UserDefaults.standard.value(forKey: Constants.Keys.UserDefaults.kNearbyWeatherApiKeyKey) == nil -> old user who never used the app or new user
        // migrationCompletedModel == nil && UserDefaults.standard.value(forKey: Constants.Keys.UserDefaults.kNearbyWeatherApiKeyKey) != nil -> old user
        guard migrationCompletedModel == nil && UserDefaults.standard.value(forKey: Constants.Keys.UserDefaults.kNearbyWeatherApiKeyKey) != nil else {
          return Completable
            .emptyCompletable
            .andThen(dependencies.applicationCycleService.createSetMigration_2_2_1_to_3_0_0_CompletedCompletable(MigrationCompletedModel(completed: true)))
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
              return Completable.emptyCompletable
            }
            return dependencies.apiKeyService.createSetApiKeyCompletable(apiKey)
          }
        
        // migrate preferences
        let migratePreferencesCompletable = Observable<(PreferencesManagerStoredContentsWrapper?, RefreshOnAppStartOptionValue, ShowTemperatureOnAppIconOptionValue)>
          .create { handler in
            let preferencesStoredContentsWrapper = try? JsonPersistencyWorker().retrieveJsonFromFile(
              with: Constants.Keys.Storage.kPreferencesManagerStoredContentsFileName,
              andDecodeAsType: PreferencesManagerStoredContentsWrapper.self,
              fromStorageLocation: .applicationSupport
            )
            
            let refreshOnAppStartValue = UserDefaults.standard.bool(forKey: Constants.Keys.UserDefaults.kRefreshOnAppStartKey) == true
            ? RefreshOnAppStartOptionValue.yes
            : RefreshOnAppStartOptionValue.no
            
            let showTemperatureAsAppIconBadgeValue = UserDefaults.standard.bool(forKey: Constants.Keys.UserDefaults.kIsTemperatureOnAppIconEnabledKey) == true
            ? ShowTemperatureOnAppIconOptionValue.yes
            : ShowTemperatureOnAppIconOptionValue.no
            
            handler.on(.next((preferencesStoredContentsWrapper, refreshOnAppStartValue, showTemperatureAsAppIconBadgeValue)))
            return Disposables.create()
          }
          .take(1)
          .asSingle()
          .flatMapCompletable { [dependencies] preferences -> Completable in
            guard let preferencesStoredContentsWrapper = preferences.0 else {
              // previous data does not exist or could not be read -> do not try to migrate these option any further
              return dependencies.preferencesService.createSetRefreshOnAppStartOptionCompletable(RefreshOnAppStartOption(value: preferences.1))
            }
            return Completable.zip([
              dependencies.weatherStationService.createSetPreferredBookmarkCompletable(preferencesStoredContentsWrapper.preferredBookmark),
              dependencies.preferencesService.createSetAmountOfNearbyResultsOptionCompletable(preferencesStoredContentsWrapper.amountOfResults),
              dependencies.preferencesService.createSetTemperatureUnitOptionCompletable(preferencesStoredContentsWrapper.temperatureUnit),
              dependencies.preferencesService.createSetDimensionalUnitsOptionCompletable(preferencesStoredContentsWrapper.windspeedUnit),
              dependencies.preferencesService.createSetSortingOrientationOptionCompletable(preferencesStoredContentsWrapper.sortingOrientation),
              dependencies.preferencesService.createSetRefreshOnAppStartOptionCompletable(RefreshOnAppStartOption(value: preferences.1)),
              dependencies.notificationService.createSetShowTemperatureOnAppIconOptionCompletable(ShowTemperatureOnAppIconOption(value: preferences.2))
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
              return Completable.emptyCompletable
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
        
        // return migration executable completable
        return Completable
          .zip([
            migrateApiKeyCompletable,
            migratePreferencesCompletable,
            migrateWeatherInformationCompletable
          ])
          // store that the migration was completed
          .andThen(dependencies.applicationCycleService.createSetMigration_2_2_1_to_3_0_0_CompletedCompletable(MigrationCompletedModel(completed: true)))
          .andThen(dependencies.applicationCycleService.createSetSetupCompletedCompletable(SetupCompletedModel(completed: true)))
          .do(onCompleted: {
            // delete previous data
            UserDefaults.standard.removeObject(forKey: Constants.Keys.UserDefaults.kNearbyWeatherApiKeyKey)
            
            try? JsonPersistencyWorker().removeFile(
              with: Constants.Keys.Storage.kPreferencesManagerStoredContentsFileName,
              fromStorageLocation: .applicationSupport
            )
            
            try? JsonPersistencyWorker().removeFile(
              with: Constants.Keys.Storage.kWeatherDataManagerStoredContentsFileName,
              fromStorageLocation: .documents
            )
          })
      }
      .do(onSubscribe: { [dependencies] in
        dependencies.migrationIsRunningSubject.onNext(true)
      })
      .do(onDispose: { [dependencies] in
        dependencies.migrationIsRunningSubject.onNext(false)
      })
  }
}
