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

extension WeatherListViewModel {
  
  struct Dependencies {
    let weatherInformationService: WeatherInformationService2
    let userLocationService: UserLocationService2
    let preferencesService: PreferencesService2
  }
}

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
      .createListTypeOptionObservable()
      .map { $0.value }
      .share(replay: 1)
  }()
  
  private lazy var preferredAmountOfResultsObservable: Observable<AmountOfResultsValue>  = { [dependencies] in
    dependencies
      .preferencesService
      .createAmountOfNearbyResultsOptionObservable()
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
  
  // MARK: - Functions
  
  public func observeEvents() {
    observeUserTapEvents()
    observeDataSource()
  }
}

// MARK: - Observations

private extension WeatherListViewModel {
  
  func observeUserTapEvents() {
    let preferredSortingOrientationObservable = dependencies
      .preferencesService
      .createSortingOrientationOptionObservable()
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
        steps?.accept(ListStep.changeAmountOfResultsAlert(currentSelectedOptionValue: preferredAmountOfResults))
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
  
  func observeDataSource() {
    let preferredSortingOrientationObservable = dependencies
      .preferencesService
      .createSortingOrientationOptionObservable()
      .map { $0.value }
      .share(replay: 1)
    
    let nearbyListItemsObservable = dependencies
      .weatherInformationService
      .createGetNearbyWeatherInformationListObservable()
//      .map { Self.sortBookmarkedResults($0, sortingWeights: sortingOrientationValue, currentLocation: currentLocation) } // TODO
      .map { [dependencies] listItems -> [BaseCellViewModelProtocol] in
        listItems.mapToWeatherInformationTableViewCellViewModel(dependencies: dependencies, isBookmark: false)
      }
      .catchError { .just([WeatherListAlertTableViewCellViewModel(dependencies: WeatherListAlertTableViewCellViewModel.Dependencies(error: $0))]) }
      .share(replay: 1)
    
    let bookmarkedListItemsObservable = Observable
      .combineLatest(
        dependencies.weatherInformationService.createGetBookmarkedWeatherInformationListObservable(),
        preferredSortingOrientationObservable,
        dependencies.userLocationService.createCurrentLocationObservable(),
        resultSelector: Self.sortNearbyResults
      )
      .map { [dependencies] in $0.mapToWeatherInformationTableViewCellViewModel(dependencies: dependencies, isBookmark: true) }
      .catchError { .just([WeatherListAlertTableViewCellViewModel(dependencies: WeatherListAlertTableViewCellViewModel.Dependencies(error: $0))]) }
      .share(replay: 1)
    
    Observable
      .combineLatest(
        nearbyListItemsObservable,
        bookmarkedListItemsObservable,
        preferredListTypeObservable,
        resultSelector: { nearbyListItems, bookmarkedListItems, preferredListType -> [TableViewSectionData] in
          switch preferredListType {
          case .bookmarked:
            return [WeatherListNearbyItemsSection(sectionCellsIdentifier: WeatherListInformationTableViewCell.reuseIdentifier, sectionItems: nearbyListItems)]
          case .nearby:
            return [WeatherListBookmarkedItemsSection(sectionCellsIdentifier: WeatherListInformationTableViewCell.reuseIdentifier, sectionItems: bookmarkedListItems)]
          }
        }
      )
      .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .userInteractive))
      .bind { [weak tableDataSource] in tableDataSource?.sectionDataSources.accept($0) }
      .disposed(by: disposeBag)
  }
}

// MARK: - Delegate Extensions

extension WeatherListViewModel: BaseTableViewSelectionDelegate {
  
  func didSelectRow(at indexPath: IndexPath) {
    guard let cellViewModel = tableDataSource.sectionDataSources[indexPath] as? WeatherListInformationTableViewCellViewModel else {
      return
    }
    Observable
      .combineLatest(
        preferredListTypeObservable,
        Observable.just(cellViewModel.weatherInformationIdentity),
        resultSelector: { preferredListTypeValue, weatherInformationIdentity -> ListStep in
          ListStep.weatherDetails2(
            identity: weatherInformationIdentity,
            isBookmark: preferredListTypeValue == .bookmarked
          )
        }
      )
      .asSingle()
      .subscribe(onSuccess: steps.accept)
      .disposed(by: disposeBag)
  }
}

// MARK: - Scene Lifecycle

extension WeatherListViewModel: ViewControllerLifeCycleRelay {
  
  func viewDidLoad() {}
  
  func viewWillAppear() {}
  
  func viewDidAppear() {}
  
  func viewWillDisappear() {}
  
  func viewDidDisappear() {}
}

// MARK: - Helpers

private extension WeatherListViewModel {
  
  static func sortNearbyResults(_ results: [PersistencyModel<WeatherInformationDTO>], sortingOrientationValue: SortingOrientationValue, currentLocation: CLLocation?) -> [PersistencyModel<WeatherInformationDTO>] {
    results.sorted { lhsValue, rhsValue -> Bool in
      let lhsEntity = lhsValue.entity
      let rhsEntity = rhsValue.entity
      
      switch sortingOrientationValue {
      case .name:
        return lhsEntity.cityName < rhsEntity.cityName
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

// MARK: - Helper Extensions

private extension Array where Element == PersistencyModel<WeatherInformationDTO> {
  
  func mapToWeatherInformationTableViewCellViewModel(dependencies: WeatherListViewModel.Dependencies, isBookmark: Bool) -> [BaseCellViewModelProtocol] {
    map { weatherInformationPersistencyModel -> WeatherListInformationTableViewCellViewModel in
      WeatherListInformationTableViewCellViewModel(
        dependencies: WeatherListInformationTableViewCellViewModel.Dependencies(
          weatherInformationIdentity: weatherInformationPersistencyModel.identity,
          isBookmark: isBookmark,
          weatherInformationService: dependencies.weatherInformationService,
          preferencesService: dependencies.preferencesService
        )
      )
    }
  }
}
