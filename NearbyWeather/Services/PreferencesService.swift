//
//  PreferencesService2.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 02.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxOptional

// MARK: - Persistency Keys

private extension PreferencesService {
  
  enum PersistencyKeys {
    case amountOfNearbyResultsOption
    case temperatureUnitOption
    case dimensionalUnitOption
    case sortingOrientationOption
    case preferredListTypeOption
    case preferredMapTypeOption
    case refreshOnAppStartOption
    
    var collection: String {
      switch self {
      case .amountOfNearbyResultsOption: return "/general_preferences/cross_platform/amount_of_results/"
      case .temperatureUnitOption: return "/general_preferences/cross_platform/temperature_unit/"
      case .dimensionalUnitOption: return "/general_preferences/cross_platform/dimensional_unit/"
      case .sortingOrientationOption: return "/general_preferences/cross_platform/sorting_orientation/"
      case .preferredListTypeOption: return "/general_preferences/ios/preferred_list_type/"
      case .preferredMapTypeOption: return "/general_preferences/cross_platform/preferred_map_type/"
      case .refreshOnAppStartOption: return "/general_preferences/ios/refresh_on_app_start/"
      }
    }
    
    var identifier: String {
      switch self {
      case .amountOfNearbyResultsOption: return "default"
      case .temperatureUnitOption: return "default"
      case .dimensionalUnitOption: return "default"
      case .sortingOrientationOption: return "default"
      case .preferredListTypeOption: return "default"
      case .preferredMapTypeOption: return "default"
      case .refreshOnAppStartOption: return "default"
      }
    }
  }
}

// MARK: - Dependencies

extension PreferencesService {
  struct Dependencies {
    let persistencyService: PersistencyProtocol
  }
}

// MARK: - Class Definition

final class PreferencesService {
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }
}

extension PreferencesService {
  
  func createSetAmountOfNearbyResultsOptionCompletable(_ option: AmountOfResultsOption) -> Completable {
    Single
      .just(option)
      .map {
        PersistencyModel<AmountOfResultsOption>(
          identity: PersistencyModelIdentity(
            collection: PersistencyKeys.amountOfNearbyResultsOption.collection,
            identifier: PersistencyKeys.amountOfNearbyResultsOption.identifier
          ),
          entity: $0
        )
      }
      .flatMapCompletable { [dependencies] in dependencies.persistencyService.saveResource($0, type: AmountOfResultsOption.self) }
  }
  
  func createGetAmountOfNearbyResultsOptionObservable() -> Observable<AmountOfResultsOption> {
    dependencies
      .persistencyService
      .observeResource(
        with: PersistencyModelIdentity(
          collection: PersistencyKeys.amountOfNearbyResultsOption.collection,
          identifier: PersistencyKeys.amountOfNearbyResultsOption.identifier
        ),
        type: AmountOfResultsOption.self
      )
      .map { $0?.entity }
      .replaceNilWith(AmountOfResultsOption(value: .ten)) // default value
  }
  
  func createSetTemperatureUnitOptionCompletable(_ option: TemperatureUnitOption) -> Completable {
    Single
      .just(option)
      .map {
        PersistencyModel<TemperatureUnitOption>(
          identity: PersistencyModelIdentity(
            collection: PersistencyKeys.temperatureUnitOption.collection,
            identifier: PersistencyKeys.temperatureUnitOption.identifier
          ),
          entity: $0
        )
      }
      .flatMapCompletable { [dependencies] in dependencies.persistencyService.saveResource($0, type: TemperatureUnitOption.self) }
  }
  
  func createGetTemperatureUnitOptionObservable() -> Observable<TemperatureUnitOption> {
    dependencies
      .persistencyService
      .observeResource(
        with: PersistencyModelIdentity(
          collection: PersistencyKeys.temperatureUnitOption.collection,
          identifier: PersistencyKeys.temperatureUnitOption.identifier
        ),
        type: TemperatureUnitOption.self
      )
      .map { $0?.entity }
      .replaceNilWith(TemperatureUnitOption(value: .celsius)) // default value
  }
  
  func createSetDimensionalUnitsOptionCompletable(_ option: DimensionalUnitOption) -> Completable {
    Single
      .just(option)
      .map {
        PersistencyModel<DimensionalUnitOption>(
          identity: PersistencyModelIdentity(
            collection: PersistencyKeys.dimensionalUnitOption.collection,
            identifier: PersistencyKeys.dimensionalUnitOption.identifier
          ),
          entity: $0
        )
      }
      .flatMapCompletable { [dependencies] in dependencies.persistencyService.saveResource($0, type: DimensionalUnitOption.self) }
  }
  
  func createGetDimensionalUnitsOptionObservable() -> Observable<DimensionalUnitOption> {
    dependencies
      .persistencyService
      .observeResource(
        with: PersistencyModelIdentity(
          collection: PersistencyKeys.dimensionalUnitOption.collection,
          identifier: PersistencyKeys.dimensionalUnitOption.identifier
        ),
        type: DimensionalUnitOption.self
      )
      .map { $0?.entity }
      .replaceNilWith(DimensionalUnitOption(value: .metric)) // default value
  }
  
  func createSetSortingOrientationOptionCompletable(_ option: SortingOrientationOption) -> Completable {
    Single
      .just(option)
      .map {
        PersistencyModel<SortingOrientationOption>(
          identity: PersistencyModelIdentity(
            collection: PersistencyKeys.sortingOrientationOption.collection,
            identifier: PersistencyKeys.sortingOrientationOption.identifier
          ),
          entity: $0
        )
      }
      .flatMapCompletable { [dependencies] in dependencies.persistencyService.saveResource($0, type: SortingOrientationOption.self) }
  }
  
  func createGetSortingOrientationOptionObservable() -> Observable<SortingOrientationOption> {
    dependencies
      .persistencyService
      .observeResource(
        with: PersistencyModelIdentity(
          collection: PersistencyKeys.sortingOrientationOption.collection,
          identifier: PersistencyKeys.sortingOrientationOption.identifier
        ),
        type: SortingOrientationOption.self
      )
      .map { $0?.entity }
      .replaceNilWith(SortingOrientationOption(value: .name)) // default value
  }
  
  func createSetListTypeOptionCompletable(_ option: ListTypeOption) -> Completable {
    Single
      .just(option)
      .map {
        PersistencyModel<ListTypeOption>(
          identity: PersistencyModelIdentity(
            collection: PersistencyKeys.preferredListTypeOption.collection,
            identifier: PersistencyKeys.preferredListTypeOption.identifier
          ),
          entity: $0
        )
      }
      .flatMapCompletable { [dependencies] in dependencies.persistencyService.saveResource($0, type: ListTypeOption.self) }
  }
  
  func createGetListTypeOptionObservable() -> Observable<ListTypeOption> {
    dependencies
      .persistencyService
      .observeResource(
        with: PersistencyModelIdentity(
          collection: PersistencyKeys.preferredListTypeOption.collection,
          identifier: PersistencyKeys.preferredListTypeOption.identifier
        ),
        type: ListTypeOption.self
      )
      .map { $0?.entity }
      .replaceNilWith(ListTypeOption(value: .nearby)) // default value
  }
  
  func createSetPreferredMapTypeOptionCompletable(_ option: MapTypeOption) -> Completable {
    Single
      .just(option)
      .map {
        PersistencyModel<MapTypeOption>(
          identity: PersistencyModelIdentity(
            collection: PersistencyKeys.preferredMapTypeOption.collection,
            identifier: PersistencyKeys.preferredMapTypeOption.identifier
          ),
          entity: $0
        )
      }
      .flatMapCompletable { [dependencies] in dependencies.persistencyService.saveResource($0, type: MapTypeOption.self) }
  }
  
  func createGetMapTypeOptionObservable() -> Observable<MapTypeOption> {
    dependencies
      .persistencyService
      .observeResource(
        with: PersistencyModelIdentity(
          collection: PersistencyKeys.preferredMapTypeOption.collection,
          identifier: PersistencyKeys.preferredMapTypeOption.identifier
        ),
        type: MapTypeOption.self
      )
      .map { $0?.entity }
      .replaceNilWith(MapTypeOption(value: .standard)) // default value
  }
  
  func createSetRefreshOnAppStartOptionCompletable(_ option: RefreshOnAppStartOption) -> Completable {
    Single
      .just(option)
      .map {
        PersistencyModel<RefreshOnAppStartOption>(
          identity: PersistencyModelIdentity(
            collection: PersistencyKeys.refreshOnAppStartOption.collection,
            identifier: PersistencyKeys.refreshOnAppStartOption.identifier
          ),
          entity: $0
        )
      }
      .flatMapCompletable { [dependencies] in dependencies.persistencyService.saveResource($0, type: RefreshOnAppStartOption.self) }
  }
  
  func createGetRefreshOnAppStartOptionObservable() -> Observable<RefreshOnAppStartOption> {
    dependencies
      .persistencyService
      .observeResource(
        with: PersistencyModelIdentity(
          collection: PersistencyKeys.refreshOnAppStartOption.collection,
          identifier: PersistencyKeys.refreshOnAppStartOption.identifier
        ),
        type: RefreshOnAppStartOption.self
      )
      .map { $0?.entity }
      .replaceNilWith(RefreshOnAppStartOption(value: .no)) // default value
  }
}

// MARK: - General Preference Persistence

protocol GeneralPreferencePersistence: WeatherListPreferencePersistence, WeatherMapPreferencePersistence, PreferenceMigration {
  func createSetAmountOfNearbyResultsOptionCompletable(_ option: AmountOfResultsOption) -> Completable
  func createGetAmountOfNearbyResultsOptionObservable() -> Observable<AmountOfResultsOption>
  
  func createSetTemperatureUnitOptionCompletable(_ option: TemperatureUnitOption) -> Completable
  func createGetTemperatureUnitOptionObservable() -> Observable<TemperatureUnitOption>
  
  func createSetDimensionalUnitsOptionCompletable(_ option: DimensionalUnitOption) -> Completable
  func createGetDimensionalUnitsOptionObservable() -> Observable<DimensionalUnitOption>
  
  func createSetSortingOrientationOptionCompletable(_ option: SortingOrientationOption) -> Completable
  func createGetSortingOrientationOptionObservable() -> Observable<SortingOrientationOption>
  
  func createSetListTypeOptionCompletable(_ option: ListTypeOption) -> Completable
  func createGetListTypeOptionObservable() -> Observable<ListTypeOption>
  
  func createSetPreferredMapTypeOptionCompletable(_ option: MapTypeOption) -> Completable
  func createGetMapTypeOptionObservable() -> Observable<MapTypeOption>
  
  func createSetRefreshOnAppStartOptionCompletable(_ option: RefreshOnAppStartOption) -> Completable
  func createGetRefreshOnAppStartOptionObservable() -> Observable<RefreshOnAppStartOption>
}

extension PreferencesService: GeneralPreferencePersistence {}

// MARK: - WeatherList Preferences
/// Preferences that are available in the WeatherList Scene

protocol WeatherListPreferencePersistence: WeatherListPreferenceSetting, WeatherListPreferenceReading {}
extension PreferencesService: WeatherListPreferencePersistence {}

protocol WeatherListPreferenceSetting {
  func createSetAmountOfNearbyResultsOptionCompletable(_ option: AmountOfResultsOption) -> Completable
  func createSetSortingOrientationOptionCompletable(_ option: SortingOrientationOption) -> Completable
  func createSetListTypeOptionCompletable(_ option: ListTypeOption) -> Completable
}

extension PreferencesService: WeatherListPreferenceSetting {}

protocol WeatherListPreferenceReading {
  func createGetAmountOfNearbyResultsOptionObservable() -> Observable<AmountOfResultsOption>
  func createGetSortingOrientationOptionObservable() -> Observable<SortingOrientationOption>
  func createGetListTypeOptionObservable() -> Observable<ListTypeOption>
}

extension PreferencesService: WeatherListPreferenceReading {}

// MARK: - WeatherMap Preferences
/// Preferences that are available in the WeatherMap Scene

protocol WeatherMapPreferencePersistence: WeatherMapPreferenceSetting, WeatherMapPreferenceReading {}
extension PreferencesService: WeatherMapPreferencePersistence {}

protocol WeatherMapPreferenceSetting {
  func createSetAmountOfNearbyResultsOptionCompletable(_ option: AmountOfResultsOption) -> Completable
  func createSetPreferredMapTypeOptionCompletable(_ option: MapTypeOption) -> Completable
}

extension PreferencesService: WeatherMapPreferenceSetting {}

protocol WeatherMapPreferenceReading {
  func createGetAmountOfNearbyResultsOptionObservable() -> Observable<AmountOfResultsOption>
  func createGetMapTypeOptionObservable() -> Observable<MapTypeOption>
  func createGetTemperatureUnitOptionObservable() -> Observable<TemperatureUnitOption>
  func createGetDimensionalUnitsOptionObservable() -> Observable<DimensionalUnitOption>
}

extension PreferencesService: WeatherMapPreferenceReading {}

// MARK: Settings Preferences
/// Preferences that are available in the Settings Scene

protocol SettingsPreferencesPersistence: SettingsPreferencesSetting, SettingsPreferencesReading {}
extension PreferencesService: SettingsPreferencesPersistence {}

protocol SettingsPreferencesSetting {
  func createSetRefreshOnAppStartOptionCompletable(_ option: RefreshOnAppStartOption) -> Completable
  func createSetTemperatureUnitOptionCompletable(_ option: TemperatureUnitOption) -> Completable
  func createSetDimensionalUnitsOptionCompletable(_ option: DimensionalUnitOption) -> Completable
}

extension PreferencesService: SettingsPreferencesSetting {}

protocol SettingsPreferencesReading {
  func createGetRefreshOnAppStartOptionObservable() -> Observable<RefreshOnAppStartOption>
  func createGetTemperatureUnitOptionObservable() -> Observable<TemperatureUnitOption>
  func createGetDimensionalUnitsOptionObservable() -> Observable<DimensionalUnitOption>
}

extension PreferencesService: SettingsPreferencesReading {}

// MARK: - AppDelegate Preferences

protocol AppDelegatePreferencePersistence: AppDelegatePreferenceSetting, AppDelegatePreferenceReading {}
extension PreferencesService: AppDelegatePreferencePersistence {}

protocol AppDelegatePreferenceSetting {
  func createSetRefreshOnAppStartOptionCompletable(_ option: RefreshOnAppStartOption) -> Completable
}

extension PreferencesService: AppDelegatePreferenceSetting {}

protocol AppDelegatePreferenceReading {
  func createGetRefreshOnAppStartOptionObservable() -> Observable<RefreshOnAppStartOption>
}

extension PreferencesService: AppDelegatePreferenceReading {}

// MARK: - Preferences Migration

protocol PreferenceMigration {
  func createSetAmountOfNearbyResultsOptionCompletable(_ option: AmountOfResultsOption) -> Completable
  func createSetTemperatureUnitOptionCompletable(_ option: TemperatureUnitOption) -> Completable
  func createSetDimensionalUnitsOptionCompletable(_ option: DimensionalUnitOption) -> Completable
  func createSetSortingOrientationOptionCompletable(_ option: SortingOrientationOption) -> Completable
  func createSetRefreshOnAppStartOptionCompletable(_ option: RefreshOnAppStartOption) -> Completable
}

extension PreferencesService: PreferenceMigration {}
