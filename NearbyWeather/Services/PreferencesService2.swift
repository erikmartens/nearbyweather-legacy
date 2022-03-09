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

private extension PreferencesService2 {
  
  enum PersistencyKeys {
    case amountOfNearbyResultsOption
    case temperatureUnitOption
    case dimensionalUnitOption
    case sortingOrientationOption
    case preferredListTypeOption
    case preferredMapTypeOption
    case refreshOnAppStartOption
    case showTemperatureAsAppIconBadge
    
    var collection: String {
      switch self {
      case .amountOfNearbyResultsOption: return "/general_preferences/cross_platform/amount_of_results/"
      case .temperatureUnitOption: return "/general_preferences/cross_platform/temperature_unit/"
      case .dimensionalUnitOption: return "/general_preferences/cross_platform/dimensional_unit/"
      case .sortingOrientationOption: return "/general_preferences/cross_platform/sorting_orientation/"
      case .preferredListTypeOption: return "/general_preferences/ios/preferred_list_type/"
      case .preferredMapTypeOption: return "/general_preferences/cross_platform/preferred_map_type/"
      case .refreshOnAppStartOption: return "/general_preferences/ios/refresh_on_app_start/"
      
      case .showTemperatureAsAppIconBadge: return "/notification_preferences/ios/show_temperature_as_app_icon_badge/"
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
      
      case .showTemperatureAsAppIconBadge: return "default"
      }
    }
  }
}

// MARK: - Dependencies

extension PreferencesService2 {
  struct Dependencies {
    let persistencyService: PersistencyProtocol
  }
}

// MARK: - Class Definition

final class PreferencesService2 {
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }
}

extension PreferencesService2 {
  
  func createSetAmountOfNearbyResultsOptionCompletable(_ option: AmountOfResultsOption) -> Completable {
    Single
      .just(option)
      .map {
        PersistencyModel<AmountOfResultsOption>(
          identity: PersistencyModelIdentity(
            collection: PreferencesService2.PersistencyKeys.amountOfNearbyResultsOption.collection,
            identifier: PreferencesService2.PersistencyKeys.amountOfNearbyResultsOption.identifier
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
          collection: PreferencesService2.PersistencyKeys.amountOfNearbyResultsOption.collection,
          identifier: PreferencesService2.PersistencyKeys.amountOfNearbyResultsOption.identifier
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
            collection: PreferencesService2.PersistencyKeys.temperatureUnitOption.collection,
            identifier: PreferencesService2.PersistencyKeys.temperatureUnitOption.identifier
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
          collection: PreferencesService2.PersistencyKeys.temperatureUnitOption.collection,
          identifier: PreferencesService2.PersistencyKeys.temperatureUnitOption.identifier
        ),
        type: TemperatureUnitOption.self
      )
      .map { $0?.entity }
      .replaceNilWith(TemperatureUnitOption(value: .celsius)) // default value
  }
  
  func createSetDimensionalUnitsOptionCompletable(_ option: DimensionalUnitsOption) -> Completable {
    Single
      .just(option)
      .map {
        PersistencyModel<DimensionalUnitsOption>(
          identity: PersistencyModelIdentity(
            collection: PreferencesService2.PersistencyKeys.dimensionalUnitOption.collection,
            identifier: PreferencesService2.PersistencyKeys.dimensionalUnitOption.identifier
          ),
          entity: $0
        )
      }
      .flatMapCompletable { [dependencies] in dependencies.persistencyService.saveResource($0, type: DimensionalUnitsOption.self) }
  }
  
  func createGetDimensionalUnitsOptionObservable() -> Observable<DimensionalUnitsOption> {
    dependencies
      .persistencyService
      .observeResource(
        with: PersistencyModelIdentity(
          collection: PreferencesService2.PersistencyKeys.dimensionalUnitOption.collection,
          identifier: PreferencesService2.PersistencyKeys.dimensionalUnitOption.identifier
        ),
        type: DimensionalUnitsOption.self
      )
      .map { $0?.entity }
      .replaceNilWith(DimensionalUnitsOption(value: .metric)) // default value
  }
  
  func createSetSortingOrientationOptionCompletable(_ option: SortingOrientationOption) -> Completable {
    Single
      .just(option)
      .map {
        PersistencyModel<SortingOrientationOption>(
          identity: PersistencyModelIdentity(
            collection: PreferencesService2.PersistencyKeys.sortingOrientationOption.collection,
            identifier: PreferencesService2.PersistencyKeys.sortingOrientationOption.identifier
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
          collection: PreferencesService2.PersistencyKeys.sortingOrientationOption.collection,
          identifier: PreferencesService2.PersistencyKeys.sortingOrientationOption.identifier
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
            collection: PreferencesService2.PersistencyKeys.preferredListTypeOption.collection,
            identifier: PreferencesService2.PersistencyKeys.preferredListTypeOption.identifier
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
          collection: PreferencesService2.PersistencyKeys.preferredListTypeOption.collection,
          identifier: PreferencesService2.PersistencyKeys.preferredListTypeOption.identifier
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
            collection: PreferencesService2.PersistencyKeys.preferredMapTypeOption.collection,
            identifier: PreferencesService2.PersistencyKeys.preferredMapTypeOption.identifier
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
          collection: PreferencesService2.PersistencyKeys.preferredMapTypeOption.collection,
          identifier: PreferencesService2.PersistencyKeys.preferredMapTypeOption.identifier
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
            collection: PreferencesService2.PersistencyKeys.refreshOnAppStartOption.collection,
            identifier: PreferencesService2.PersistencyKeys.refreshOnAppStartOption.identifier
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
          collection: PreferencesService2.PersistencyKeys.refreshOnAppStartOption.collection,
          identifier: PreferencesService2.PersistencyKeys.refreshOnAppStartOption.identifier
        ),
        type: RefreshOnAppStartOption.self
      )
      .map { $0?.entity }
      .replaceNilWith(RefreshOnAppStartOption(value: .yes)) // default value
  }
  
  func createSetShowTemperatureOnAppIconOptionCompletable(_ option: ShowTemperatureOnAppIconOption) -> Completable {
    Single
      .just(option)
      .map {
        PersistencyModel<ShowTemperatureOnAppIconOption>(
          identity: PersistencyModelIdentity(
            collection: PreferencesService2.PersistencyKeys.showTemperatureAsAppIconBadge.collection,
            identifier: PreferencesService2.PersistencyKeys.showTemperatureAsAppIconBadge.identifier
          ),
          entity: $0
        )
      }
      .flatMapCompletable { [dependencies] in dependencies.persistencyService.saveResource($0, type: ShowTemperatureOnAppIconOption.self) }
  }
  
  func createGetShowTemperatureOnAppIconOptionObservable() -> Observable<ShowTemperatureOnAppIconOption> {
    dependencies
      .persistencyService
      .observeResource(
        with: PersistencyModelIdentity(
          collection: PreferencesService2.PersistencyKeys.showTemperatureAsAppIconBadge.collection,
          identifier: PreferencesService2.PersistencyKeys.showTemperatureAsAppIconBadge.identifier
        ),
        type: ShowTemperatureOnAppIconOption.self
      )
      .map { $0?.entity }
      .replaceNilWith(ShowTemperatureOnAppIconOption(value: .no)) // default value
  }
}

// MARK: - General Preference Persistence

protocol GeneralPreferencePersistence: WeatherListPreferencePersistence, WeatherMapPreferencePersistence, PreferenceMigration {
  func createSetAmountOfNearbyResultsOptionCompletable(_ option: AmountOfResultsOption) -> Completable
  func createGetAmountOfNearbyResultsOptionObservable() -> Observable<AmountOfResultsOption>
  
  func createSetTemperatureUnitOptionCompletable(_ option: TemperatureUnitOption) -> Completable
  func createGetTemperatureUnitOptionObservable() -> Observable<TemperatureUnitOption>
  
  func createSetDimensionalUnitsOptionCompletable(_ option: DimensionalUnitsOption) -> Completable
  func createGetDimensionalUnitsOptionObservable() -> Observable<DimensionalUnitsOption>
  
  func createSetSortingOrientationOptionCompletable(_ option: SortingOrientationOption) -> Completable
  func createGetSortingOrientationOptionObservable() -> Observable<SortingOrientationOption>
  
  func createSetListTypeOptionCompletable(_ option: ListTypeOption) -> Completable
  func createGetListTypeOptionObservable() -> Observable<ListTypeOption>
  
  func createSetPreferredMapTypeOptionCompletable(_ option: MapTypeOption) -> Completable
  func createGetMapTypeOptionObservable() -> Observable<MapTypeOption>
  
  func createSetRefreshOnAppStartOptionCompletable(_ option: RefreshOnAppStartOption) -> Completable
  func createGetRefreshOnAppStartOptionObservable() -> Observable<RefreshOnAppStartOption>
}

extension PreferencesService2: GeneralPreferencePersistence {}

// MARK: - WeatherList Preferences
/// Preferences that are available in the WeatherList Scene

protocol WeatherListPreferencePersistence: WeatherListPreferenceSetting, WeatherListPreferenceReading {}
extension PreferencesService2: WeatherListPreferencePersistence {}

protocol WeatherListPreferenceSetting {
  func createSetAmountOfNearbyResultsOptionCompletable(_ option: AmountOfResultsOption) -> Completable
  func createSetSortingOrientationOptionCompletable(_ option: SortingOrientationOption) -> Completable
  func createSetListTypeOptionCompletable(_ option: ListTypeOption) -> Completable
}

extension PreferencesService2: WeatherListPreferenceSetting {}

protocol WeatherListPreferenceReading {
  func createGetAmountOfNearbyResultsOptionObservable() -> Observable<AmountOfResultsOption>
  func createGetSortingOrientationOptionObservable() -> Observable<SortingOrientationOption>
  func createGetListTypeOptionObservable() -> Observable<ListTypeOption>
}

extension PreferencesService2: WeatherListPreferenceReading {}

// MARK: - WeatherMap Preferences
/// Preferences that are available in the WeatherMap Scene

protocol WeatherMapPreferencePersistence: WeatherMapPreferenceSetting, WeatherMapPreferenceReading {}
extension PreferencesService2: WeatherMapPreferencePersistence {}

protocol WeatherMapPreferenceSetting {
  func createSetAmountOfNearbyResultsOptionCompletable(_ option: AmountOfResultsOption) -> Completable
  func createSetPreferredMapTypeOptionCompletable(_ option: MapTypeOption) -> Completable
}

extension PreferencesService2: WeatherMapPreferenceSetting {}

protocol WeatherMapPreferenceReading {
  func createGetAmountOfNearbyResultsOptionObservable() -> Observable<AmountOfResultsOption>
  func createGetMapTypeOptionObservable() -> Observable<MapTypeOption>
  func createGetTemperatureUnitOptionObservable() -> Observable<TemperatureUnitOption>
  func createGetDimensionalUnitsOptionObservable() -> Observable<DimensionalUnitsOption>
}

extension PreferencesService2: WeatherMapPreferenceReading {}

// MARK: Settings Preferences
/// Preferences that are available in the Settings Scene

protocol SettingsPreferencesPersistence: SettingsPreferencesSetting, SettingsPreferencesReading {}
extension PreferencesService2: SettingsPreferencesPersistence {}

protocol SettingsPreferencesSetting {
  func createSetShowTemperatureOnAppIconOptionCompletable(_ option: ShowTemperatureOnAppIconOption) -> Completable
  func createSetRefreshOnAppStartOptionCompletable(_ option: RefreshOnAppStartOption) -> Completable
  func createSetTemperatureUnitOptionCompletable(_ option: TemperatureUnitOption) -> Completable
  func createSetDimensionalUnitsOptionCompletable(_ option: DimensionalUnitsOption) -> Completable
}

extension PreferencesService2: SettingsPreferencesSetting {}

protocol SettingsPreferencesReading {
  func createGetShowTemperatureOnAppIconOptionObservable() -> Observable<ShowTemperatureOnAppIconOption>
  func createGetRefreshOnAppStartOptionObservable() -> Observable<RefreshOnAppStartOption>
  func createGetTemperatureUnitOptionObservable() -> Observable<TemperatureUnitOption>
  func createGetDimensionalUnitsOptionObservable() -> Observable<DimensionalUnitsOption>
}

extension PreferencesService2: SettingsPreferencesReading {}

// MARK: - Notification Preferences

protocol NotificationPreferencesPersistence: NotificationPreferencesSetting, NotificationPreferencesReading {}
extension PreferencesService2: NotificationPreferencesPersistence {}

protocol NotificationPreferencesSetting {
  func createSetShowTemperatureOnAppIconOptionCompletable(_ option: ShowTemperatureOnAppIconOption) -> Completable
}

extension PreferencesService2: NotificationPreferencesSetting {}

protocol NotificationPreferencesReading {
  func createGetShowTemperatureOnAppIconOptionObservable() -> Observable<ShowTemperatureOnAppIconOption>
}

extension PreferencesService2: NotificationPreferencesReading {}

// MARK: - AppDelegate Preferences

protocol AppDelegatePreferencePersistence: AppDelegatePreferenceSetting, AppDelegatePreferenceReading {}
extension PreferencesService2: AppDelegatePreferencePersistence {}

protocol AppDelegatePreferenceSetting {
  func createSetRefreshOnAppStartOptionCompletable(_ option: RefreshOnAppStartOption) -> Completable
}

extension PreferencesService2: AppDelegatePreferenceSetting {}

protocol AppDelegatePreferenceReading {
  func createGetRefreshOnAppStartOptionObservable() -> Observable<RefreshOnAppStartOption>
}

extension PreferencesService2: AppDelegatePreferenceReading {}

// MARK: - Preferences Migration

protocol PreferenceMigration {
  func createSetAmountOfNearbyResultsOptionCompletable(_ option: AmountOfResultsOption) -> Completable
  func createSetTemperatureUnitOptionCompletable(_ option: TemperatureUnitOption) -> Completable
  func createSetDimensionalUnitsOptionCompletable(_ option: DimensionalUnitsOption) -> Completable
  func createSetSortingOrientationOptionCompletable(_ option: SortingOrientationOption) -> Completable
  func createSetRefreshOnAppStartOptionCompletable(_ option: RefreshOnAppStartOption) -> Completable
  func createSetShowTemperatureOnAppIconOptionCompletable(_ option: ShowTemperatureOnAppIconOption) -> Completable
}

extension PreferencesService2: PreferenceMigration {}
