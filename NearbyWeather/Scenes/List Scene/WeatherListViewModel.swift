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

extension WeatherListViewModel {
  
  struct Dependencies {
    let weatherInformationService: WeatherInformationService2
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
  
  var tableDelegate: WeatherListTableViewDelegate?
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
        Observable
          .zip([dependencies.weatherInformationService.createUpdateNearbyWeatherInformationCompletable().asObservable(),
                dependencies.weatherInformationService.createUpdateBookmarkedWeatherInformationCompletable().asObservable()])
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
    
    let nearbyListItemsObservable = Observable
      .combineLatest(
        preferredListTypeObservable,
        dependencies.weatherInformationService.createGetNearbyWeatherInformationListObservable(),
        resultSelector: { listTypeValue, nearbyWeatherInformationItems -> [PersistencyModel<WeatherInformationDTO>] in
          listTypeValue == .nearby ? nearbyWeatherInformationItems : []
        }
      )
      .map { [dependencies] in $0.mapToWeatherListTableViewCellViewModel(dependencies: dependencies, isBookmark: false) }
      .share(replay: 1)
    
    let bookmarkedListItemsObservable = Observable
      .combineLatest(
        preferredListTypeObservable,
        preferredSortingOrientationObservable,
        dependencies.weatherInformationService.createGetBookmarkedWeatherInformationListObservable(),
        resultSelector: { listTypeValue, sortingOrientationValue, nearbyWeatherInformationItems -> [PersistencyModel<WeatherInformationDTO>] in
          listTypeValue == .bookmarked
            ? Self.sortNearbyResults(nearbyWeatherInformationItems, using: sortingOrientationValue)
            : []
        }
      )
      .map { [dependencies] in $0.mapToWeatherListTableViewCellViewModel(dependencies: dependencies, isBookmark: true) }
      .share(replay: 1)
    
    Observable
      .combineLatest(
        nearbyListItemsObservable,
        bookmarkedListItemsObservable,
        resultSelector: { nearbyListItems, bookmarkedListItems -> [TableViewSectionData] in
          [WeatherListNearbyItemsSection(sectionCellsIdentifier: WeatherInformationTableViewCell.reuseIdentifier, sectionItems: nearbyListItems),
           WeatherListBookmarkedItemsSection(sectionCellsIdentifier: WeatherInformationTableViewCell.reuseIdentifier, sectionItems: bookmarkedListItems)]
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
    guard let cellViewModel = tableDataSource.sectionDataSources[indexPath] as? WeatherInformationTableViewCellViewModel else {
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

private extension Array where Element == PersistencyModel<WeatherInformationDTO> {
  
  func mapToWeatherListTableViewCellViewModel(dependencies: WeatherListViewModel.Dependencies, isBookmark: Bool) -> [WeatherInformationTableViewCellViewModel] {
    map { weatherInformationPersistencyModel -> WeatherInformationTableViewCellViewModel in
      WeatherInformationTableViewCellViewModel(
        dependencies: WeatherInformationTableViewCellViewModel.Dependencies(
          weatherInformationIdentity: weatherInformationPersistencyModel.identity,
          isBookmark: isBookmark,
          weatherInformationService: dependencies.weatherInformationService,
          preferencesService: dependencies.preferencesService
        )
      )
    }
  }
}

private extension WeatherListViewModel {
  
  // TODO: move to weather service
  static func sortNearbyResults(_ results: [PersistencyModel<WeatherInformationDTO>], using sortingOrientationValue: SortingOrientationValue) -> [PersistencyModel<WeatherInformationDTO>] {
    results.sorted { lhsValue, rhsValue -> Bool in
      switch sortingOrientationValue {
      case .name:
        return lhsValue.entity.cityName > rhsValue.entity.cityName
      case .temperature:
        return (lhsValue.entity.atmosphericInformation.temperatureKelvin ?? 0) > (rhsValue.entity.atmosphericInformation.temperatureKelvin ?? 0)
      case .distance:
        return lhsValue.entity.cityName > rhsValue.entity.cityName // TODO: use correct values
      }
    }
  }
}
