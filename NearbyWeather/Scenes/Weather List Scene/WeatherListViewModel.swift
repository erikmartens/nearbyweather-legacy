//
//  WeatherListViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa
import RxFlow
import CoreLocation

// MARK: - Dependencies

extension WeatherListViewModel {
  struct Dependencies {
    let weatherInformationService: WeatherInformationPersistence & WeatherInformationUpdating
    let weatherStationService: WeatherStationBookmarkReading
    let userLocationService: UserLocationReading
    let preferencesService: WeatherListPreferencePersistence & WeatherMapPreferenceReading
    let apiKeyService: ApiKeyReading
  }
}

// MARK: - Class Definition

final class WeatherListViewModel: NSObject, Stepper, BaseViewModel {
  
  // MARK: - Routing
  
  let steps = PublishRelay<Step>()
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  var tableDelegate: WeatherListTableViewDelegate? // swiftlint:disable:this weak_delegate
  let tableDataSource: WeatherListTableViewDataSource
  
  // MARK: - Events
  
  let onDidTapListTypeBarButtonSubject = PublishSubject<Void>()
  let onDidTapAmountOfResultsBarButtonSubject = PublishSubject<Void>()
  let onDidTapSortingOrientationBarButtonSubject = PublishSubject<Void>()
  let onDidPullToRefreshSubject = PublishSubject<Void>()
  
  private let isRefreshingSubject = BehaviorSubject<Bool>(value: false)
  
  // MARK: - Drivers
  
  lazy var isRefreshingDriver = isRefreshingSubject.asDriver(onErrorJustReturn: false)
  lazy var preferredListTypeDriver = preferredListTypeObservable.asDriver(onErrorJustReturn: .bookmarked)
  lazy var preferredAmountOfResultsDriver = preferredAmountOfResultsObservable.asDriver(onErrorJustReturn: .ten)
  
  // MARK: - Observables
  
  private lazy var preferredListTypeObservable: Observable<ListTypeValue> = { [dependencies] in
    dependencies
      .preferencesService
      .createGetListTypeOptionObservable()
      .map { $0.value }
      .share(replay: 1)
  }()
  
  private lazy var preferredAmountOfResultsObservable: Observable<AmountOfResultsValue>  = { [dependencies] in
    dependencies
      .preferencesService
      .createGetAmountOfNearbyResultsOptionObservable()
      .map { $0.value }
      .share(replay: 1)
  }()
  
  // MARK: - Initialization
  
  required init(dependencies: Dependencies) {
    self.dependencies = dependencies
    tableDataSource = WeatherListTableViewDataSource()
    super.init()
    
    tableDelegate = WeatherListTableViewDelegate(cellSelectionDelegate: self)
  }
  
  deinit {
    printDebugMessage(
      domain: String(describing: self),
      message: "was deinitialized",
      type: .info
    )
  }
  
  // MARK: - Functions
  
  func observeEvents() {
    observeDataSource()
    observeUserTapEvents()
  }
}

// MARK: - Observations

extension WeatherListViewModel {

  func observeDataSource() {
    let apiKeyValidObservable = dependencies
      .apiKeyService
      .createGetApiKeyObservable()
      .share(replay: 1)
    
    let preferredSortingOrientationObservable = dependencies
      .preferencesService
      .createGetSortingOrientationOptionObservable()
      .map { $0.value }
      .share(replay: 1)
    
    let nearbyListItemsObservable = Observable
      .combineLatest(
        dependencies.weatherInformationService.createGetNearbyWeatherInformationListObservable(),
        preferredSortingOrientationObservable,
        dependencies.userLocationService.createGetCurrentLocationObservable(),
        apiKeyValidObservable,
        resultSelector: { weatherInformationItems, sortingOrientation, currentLocation, _ in
          Self.sortNearbyResults(weatherInformationItems, sortingOrientationValue: sortingOrientation, currentLocation: currentLocation)
        }
      )
      .map { [dependencies] in $0.mapToWeatherInformationTableViewCellViewModel(dependencies: dependencies, isBookmark: false) }
      .map { [WeatherListNearbyItemsSection(sectionCellsIdentifier: WeatherListInformationTableViewCell.reuseIdentifier, sectionItems: $0)] }
      .catchError { error -> Observable<[TableViewSectionData]> in error.mapToObservableTableSectionData() }
      .share(replay: 1)
    
    let bookmarkedListItemsObservable = Observable
      .combineLatest(
        dependencies.weatherInformationService.createGetBookmarkedWeatherInformationListObservable(),
        dependencies.weatherStationService.createGetBookmarksSortingObservable(),
        apiKeyValidObservable,
        resultSelector: { weatherInformationItems, sortingWeights, _ in
          Self.sortBookmarkedResults(weatherInformationItems, sortingWeights: sortingWeights)
        }
      )
      .map { [dependencies] in $0.mapToWeatherInformationTableViewCellViewModel(dependencies: dependencies, isBookmark: true) }
      .map { [WeatherListBookmarkedItemsSection(sectionCellsIdentifier: WeatherListInformationTableViewCell.reuseIdentifier, sectionItems: $0)] }
      .catchError { error -> Observable<[TableViewSectionData]> in error.mapToObservableTableSectionData() }
      .share(replay: 1)
    
    Observable
      .combineLatest(
        nearbyListItemsObservable,
        bookmarkedListItemsObservable,
        preferredListTypeObservable,
        resultSelector: { nearbyListSections, bookmarkedListSections, preferredListType -> [TableViewSectionData] in
          switch preferredListType {
          case .nearby:
            return nearbyListSections
          case .bookmarked:
            return bookmarkedListSections
          }
        }
      )
      .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
      .bind { [weak tableDataSource] in tableDataSource?.sectionDataSources.accept($0) }
      .disposed(by: disposeBag)
  }
  
  func observeUserTapEvents() {
    let preferredSortingOrientationObservable = dependencies
      .preferencesService
      .createGetSortingOrientationOptionObservable()
      .map { $0.value }
      .share(replay: 1)
    
    onDidTapListTypeBarButtonSubject
      .flatMapLatest { [unowned preferredListTypeObservable] in preferredListTypeObservable }
      .subscribe(onNext: { [weak steps] preferredListType in
        steps?.accept(ListStep.changeListTypeAlert(currentSelectedOptionValue: preferredListType))
      })
      .disposed(by: disposeBag)
    
    onDidTapAmountOfResultsBarButtonSubject
      .flatMapLatest { [unowned preferredAmountOfResultsObservable] in preferredAmountOfResultsObservable }
      .subscribe(onNext: { [weak steps] preferredAmountOfResults in
        steps?.accept(ListStep.changeAmountOfResultsAlert(selectionDelegate: self, currentSelectedOptionValue: preferredAmountOfResults))
      })
      .disposed(by: disposeBag)
    
    onDidTapSortingOrientationBarButtonSubject
      .flatMapLatest { [unowned preferredSortingOrientationObservable] in preferredSortingOrientationObservable }
      .subscribe(onNext: { [weak steps] preferredSortingOrientation in
        steps?.accept(ListStep.changeSortingOrientationAlert(currentSelectedOptionValue: preferredSortingOrientation))
      })
      .disposed(by: disposeBag)
    
    onDidPullToRefreshSubject
      .do(onNext: { [weak isRefreshingSubject] in isRefreshingSubject?.onNext(true) })
      .flatMapLatest { [dependencies] _ -> Observable<Void> in
        Completable
          .zip([dependencies.weatherInformationService.createUpdateNearbyWeatherInformationCompletable(),
                dependencies.weatherInformationService.createUpdateBookmarkedWeatherInformationCompletable()])
          .asObservable()
          .map { _ in () }
      }
      .subscribe { [weak isRefreshingSubject] _ in
        isRefreshingSubject?.onNext(false)
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - Delegate Extensions

extension WeatherListViewModel: BaseTableViewSelectionDelegate {
  
  func didSelectRow(at indexPath: IndexPath) {
    guard let cellViewModel = tableDataSource.sectionDataSources[indexPath] as? WeatherListInformationTableViewCellViewModel else {
      return
    }
    _ = Observable
      .just(cellViewModel.weatherInformationIdentity)
      .map(ListStep.weatherDetails2)
      .take(1)
      .asSingle()
      .subscribe(onSuccess: steps.accept)
  }
}

// MARK: - Helpers

private extension WeatherListViewModel {
  
  static func sortBookmarkedResults(_ persistedWeatherInformationDTOs: [PersistencyModel<WeatherInformationDTO>], sortingWeights: [Int: Int]?) -> [PersistencyModel<WeatherInformationDTO>] {
    persistedWeatherInformationDTOs.sorted { lhsModel, rhsModel -> Bool in
      let lhsSortingWeight = sortingWeights?[lhsModel.entity.stationIdentifier] ?? 999
      let rhsSortingWeight = sortingWeights?[rhsModel.entity.stationIdentifier] ?? 999
      if lhsSortingWeight == rhsSortingWeight {
        return lhsModel.entity.stationName < rhsModel.entity.stationName
      }
      return lhsSortingWeight < rhsSortingWeight
    }
  }
  
  static func sortNearbyResults(_ results: [PersistencyModel<WeatherInformationDTO>], sortingOrientationValue: SortingOrientationValue, currentLocation: CLLocation?) -> [PersistencyModel<WeatherInformationDTO>] {
    results.sorted { lhsValue, rhsValue -> Bool in
      let lhsEntity = lhsValue.entity
      let rhsEntity = rhsValue.entity
      
      switch sortingOrientationValue {
      case .name:
        return lhsEntity.stationName < rhsEntity.stationName
      case .temperature:
        guard let lhsTemperature = lhsEntity.atmosphericInformation.temperatureKelvin else {
          return false
        }
        guard let rhsTemperature = rhsEntity.atmosphericInformation.temperatureKelvin else {
          return true
        }
        return lhsTemperature > rhsTemperature
      case .distance:
        guard let currentLocation = currentLocation else {
            return false
        }
        guard let lhsLatitude = lhsEntity.coordinates.latitude, let lhsLongitude = lhsEntity.coordinates.longitude else {
          return false
        }
        guard let rhsLatitude = rhsEntity.coordinates.latitude, let rhsLongitude = rhsEntity.coordinates.longitude else {
          return true
        }
        let lhsLocation = CLLocation(latitude: lhsLatitude, longitude: lhsLongitude)
        let rhsLocation = CLLocation(latitude: rhsLatitude, longitude: rhsLongitude)
        return lhsLocation.distance(from: currentLocation) < rhsLocation.distance(from: currentLocation)
      }
    }
  }
}

// MARK: - Delegate Extensions

extension WeatherListViewModel: AmountOfResultsSelectionAlertDelegate {
  
  func didSelectAmountOfResultsOption(_ selectedOption: AmountOfResultsOption) {
    _ = dependencies.preferencesService
      .createSetAmountOfNearbyResultsOptionCompletable(selectedOption)
      .subscribe()
  }
}

// MARK: - Helper Extensions

private extension Error {
  
  func mapToObservableTableSectionData() -> Observable<[TableViewSectionData]> {
    Observable
      .just([WeatherListAlertTableViewCellViewModel(dependencies: WeatherListAlertTableViewCellViewModel.Dependencies(error: self))])
      .map { [WeatherListAlertItemsSection(sectionCellsIdentifier: WeatherListAlertTableViewCell.reuseIdentifier, sectionItems: $0)] }
  }
}

private extension Array where Element == PersistencyModel<WeatherInformationDTO> {
  
  func mapToWeatherInformationTableViewCellViewModel(dependencies: WeatherListViewModel.Dependencies, isBookmark: Bool) -> [BaseCellViewModelProtocol] {
    map { weatherInformationPersistencyModel -> WeatherListInformationTableViewCellViewModel in
      WeatherListInformationTableViewCellViewModel(
        dependencies: WeatherListInformationTableViewCellViewModel.Dependencies(
          weatherInformationIdentity: weatherInformationPersistencyModel.identity,
          weatherStationService: dependencies.weatherStationService,
          weatherInformationService: dependencies.weatherInformationService,
          preferencesService: dependencies.preferencesService
        )
      )
    }
  }
}
