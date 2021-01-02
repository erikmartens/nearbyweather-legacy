//
//  PreferencesService2.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 02.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxOptional

extension PreferencesService2 {
  
  enum PersistencyKeys {
    case amountOfNearbyResultsOption
    case temperatureUnitOption
    case dimensionalUnitOption
    case sortingOrientationOption
    case preferredListTypeOption
    case preferredMapTypeOption
    
    case weatherStationBookmarks
    case weatherStationBookmarksSorting
    case weatherStationPreferredBookmark
    
    var collection: String {
      switch self {
      case .amountOfNearbyResultsOption: return "/general_preferences/amount_of_results/"
      case .temperatureUnitOption: return "/general_preferences/temperature_unit/"
      case .dimensionalUnitOption: return "/general_preferences/dimensional_unit/"
      case .sortingOrientationOption: return "/general_preferences/sorting_orientation/"
      case .preferredListTypeOption: return "/general_preferences/preferred_list_type/"
      case .preferredMapTypeOption: return "/general_preferences/preferred_map_type/"
      
      case .weatherStationBookmarks: return "/weather_station/bookmarks/"
      case .weatherStationBookmarksSorting: return "/weather_station/bookmarks_sorting/"
      case .weatherStationPreferredBookmark: return "/weather_station/preferred_bookmark/"
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
        
      case .weatherStationBookmarks: return "default"
      case .weatherStationBookmarksSorting: return "default"
      case .weatherStationPreferredBookmark: return "default"
      }
    }
  }
}

final class PreferencesService2 {
  
  // MARK: - Assets
  
  private lazy var persistencyWorker: RealmPersistencyWorker = {
    try! RealmPersistencyWorker(
      storageLocation: .documents,
      dataBaseFileName: "PreferencesServiceDataBase"
    )
  }()
  
  // MARK: - Properties
  
  // MARK: - Initialization
}

// MARK: - General Preference Setting

protocol GeneralPreferenceSetting {
  func setAmountOfNearbyResultsOption(_ option: AmountOfResultsOption) -> Completable
  func getAmountOfNearbyResultsOption() -> Observable<AmountOfResultsOption>
  
  func setTemperatureUnitOption(_ option: TemperatureUnitOption) -> Completable
  func getTemperatureUnitOption() -> Observable<TemperatureUnitOption>
  
  func setDimensionalUnitsOption(_ option: DimensionalUnitsOption) -> Completable
  func getDimensionalUnitsOption() -> Observable<DimensionalUnitsOption>
  
  func setSortingOrientationOption(_ option: SortingOrientationOption) -> Completable
  func getSortingOrientationOption() -> Observable<SortingOrientationOption>
  
  func setPreferredListTypeOption(_ option: ListTypeOption) -> Completable
  func createPreferredListTypeOptionObservable() -> Observable<ListTypeOption>
  
  func setPreferredMapTypeOption(_ option: MapTypeOption) -> Completable
  func getPreferredMapTypeOption() -> Observable<MapTypeOption>
}

extension PreferencesService2: GeneralPreferenceSetting {
  
  func setAmountOfNearbyResultsOption(_ option: AmountOfResultsOption) -> Completable {
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
      .flatMapCompletable { [persistencyWorker] in persistencyWorker.saveResource($0, type: AmountOfResultsOption.self) }
  }
  
  func getAmountOfNearbyResultsOption() -> Observable<AmountOfResultsOption> {
    persistencyWorker
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
  
  func setTemperatureUnitOption(_ option: TemperatureUnitOption) -> Completable {
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
      .flatMapCompletable { [persistencyWorker] in persistencyWorker.saveResource($0, type: TemperatureUnitOption.self) }
  }
  
  func getTemperatureUnitOption() -> Observable<TemperatureUnitOption> {
    persistencyWorker
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
  
  func setDimensionalUnitsOption(_ option: DimensionalUnitsOption) -> Completable {
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
      .flatMapCompletable { [persistencyWorker] in persistencyWorker.saveResource($0, type: DimensionalUnitsOption.self) }
  }
  
  func getDimensionalUnitsOption() -> Observable<DimensionalUnitsOption> {
    persistencyWorker
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
  
  func setSortingOrientationOption(_ option: SortingOrientationOption) -> Completable {
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
      .flatMapCompletable { [persistencyWorker] in persistencyWorker.saveResource($0, type: SortingOrientationOption.self) }
  }
  
  func getSortingOrientationOption() -> Observable<SortingOrientationOption> {
    persistencyWorker
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
  
  func setPreferredListTypeOption(_ option: ListTypeOption) -> Completable {
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
      .flatMapCompletable { [persistencyWorker] in persistencyWorker.saveResource($0, type: ListTypeOption.self) }
  }
  
  func createPreferredListTypeOptionObservable() -> Observable<ListTypeOption> {
    persistencyWorker
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
  
  func setPreferredMapTypeOption(_ option: MapTypeOption) -> Completable {
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
      .flatMapCompletable { [persistencyWorker] in persistencyWorker.saveResource($0, type: MapTypeOption.self) }
  }
  
  func getPreferredMapTypeOption() -> Observable<MapTypeOption> {
    persistencyWorker
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
}

// MARK: - Weather Station Bookmarking

protocol WeatherStationBookmarkSetting {
  func addBookmark(_ weatherStationDto: WeatherStationDTO) -> Completable
  func removeBookmark(_ weatherStationDto: WeatherStationDTO) -> Completable
  func createBookmarkedStationsObservable() -> Observable<[WeatherStationDTO]>
  
  func setBookmarksSorting(_ sorting: [String: Int]) -> Completable
  func getBookmarksSorting() -> Observable<[String: Int]?>
  
  func setPreferredBookmark(_ weatherStationDto: PreferredBookmarkOption) -> Completable
  func clearPreferredBookmark() -> Completable
  func createPreferredBookmarkObservable() -> Observable<PreferredBookmarkOption?>
}

extension PreferencesService2: WeatherStationBookmarkSetting {
  
  func addBookmark(_ weatherStationDto: WeatherStationDTO) -> Completable {
    Single
      .just(weatherStationDto)
      .map {
        PersistencyModel<WeatherStationDTO>(
          identity: PersistencyModelIdentity(
            collection: PreferencesService2.PersistencyKeys.weatherStationBookmarks.collection,
            identifier: String($0.identifier)
          ),
          entity: $0
        )
      }
      .flatMapCompletable { [persistencyWorker] in persistencyWorker.saveResource($0, type: WeatherStationDTO.self) }
  }
  
  func removeBookmark(_ weatherStationDto: WeatherStationDTO) -> Completable {
    Single
      .just(weatherStationDto.identifier)
      .map {
        PersistencyModelIdentity(
          collection: PreferencesService2.PersistencyKeys.weatherStationBookmarks.collection,
          identifier: String($0)
        )
      }
      .flatMapCompletable { [persistencyWorker] in persistencyWorker.deleteResource(with: $0) }
  }
  
  func setBookmarksSorting(_ sorting: [String: Int]) -> Completable {
    Single
      .just(sorting)
      .map {
        PersistencyModel(
          identity: PersistencyModelIdentity(
            collection: PreferencesService2.PersistencyKeys.weatherStationBookmarksSorting.collection,
            identifier: PreferencesService2.PersistencyKeys.weatherStationBookmarksSorting.identifier
          ),
          entity: $0
        )
      }
      .flatMapCompletable { [persistencyWorker] in persistencyWorker.saveResource($0, type: [String: Int].self) }
  }
  
  func getBookmarksSorting() -> Observable<[String: Int]?> {
    persistencyWorker
      .observeResource(
        with: PersistencyModelIdentity(
          collection: PreferencesService2.PersistencyKeys.weatherStationBookmarksSorting.collection,
          identifier: PreferencesService2.PersistencyKeys.weatherStationBookmarksSorting.identifier
        ),
        type: [String: Int].self
      )
      .map { $0?.entity }
  }
  
  func createBookmarkedStationsObservable() -> Observable<[WeatherStationDTO]> {
    persistencyWorker
      .observeResources(in: PreferencesService2.PersistencyKeys.weatherStationBookmarks.collection, type: WeatherStationDTO.self)
      .map { $0.map { $0.entity } }
  }
  
  func setPreferredBookmark(_ weatherStationDto: PreferredBookmarkOption) -> Completable {
    Single
      .just(weatherStationDto)
      .map {
        PersistencyModel(
          identity: PersistencyModelIdentity(
            collection: PreferencesService2.PersistencyKeys.weatherStationPreferredBookmark.collection,
            identifier: PreferencesService2.PersistencyKeys.weatherStationPreferredBookmark.identifier
          ),
          entity: $0
        )
      }
      .flatMapCompletable { [persistencyWorker] in persistencyWorker.saveResource($0, type: PreferredBookmarkOption.self) }
  }
  
  func clearPreferredBookmark() -> Completable {
    persistencyWorker
      .deleteResource(
        with: PersistencyModelIdentity(
          collection: PreferencesService2.PersistencyKeys.weatherStationPreferredBookmark.collection,
          identifier: PreferencesService2.PersistencyKeys.weatherStationPreferredBookmark.identifier
        )
      )
  }
  
  func createPreferredBookmarkObservable() -> Observable<PreferredBookmarkOption?> {
    persistencyWorker
      .observeResources(in: PreferencesService2.PersistencyKeys.weatherStationPreferredBookmark.collection, type: PreferredBookmarkOption.self)
      .map { $0.first }
      .errorOnNil()
      .map { $0.entity }
      .catchErrorJustReturn(nil)
  }
}
