//
//  ManageBookmarksViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 15.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa
import RxFlow
import PKHUD

// MARK: - Dependencies

extension ManageBookmarksViewModel {
  struct Dependencies {
    let weatherStationService: WeatherStationBookmarkSetting & WeatherStationBookmarkReading
  }
}

// MARK: - Class Definition

final class ManageBookmarksViewModel: NSObject, Stepper, BaseViewModel {
  
  // MARK: - Routing
  
  let steps = PublishRelay<Step>()
  
  // MARK: - Assets
  
  private var disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  var tableDelegate: ManageBookmarksTableViewDelegate? // swiftlint:disable:this weak_delegate
  var tableDataSource: ManageBookmarksTableViewDataSource!
  
  // MARK: - Events
  
  // MARK: - Drivers
  
  // MARK: - Observables
  
  private lazy var bookmarkedStationsObservable =  dependencies.weatherStationService.createGetBookmarkedStationsObservable()
  private lazy var bookmarkedStationsCountObservable = bookmarkedStationsObservable.map { $0.count }
  
  private lazy var bookmarksInOrderObservable: Observable<[WeatherStationDTO]> = Observable
    .combineLatest(
      bookmarkedStationsObservable,
      dependencies.weatherStationService.createGetBookmarksSortingObservable()
    )
    .map { bookmarks, sorting -> [WeatherStationDTO] in
      bookmarks
        .sorted { lhsBookmark, rhsBookmark in
          let lhsSortingWeight = sorting?[lhsBookmark.identifier] ?? 999
          let rhsSortingWeight = sorting?[rhsBookmark.identifier] ?? 999
          if lhsSortingWeight == rhsSortingWeight {
            return lhsBookmark.name < rhsBookmark.name
          }
          return lhsSortingWeight < rhsSortingWeight
        }
    }
  
  // MARK: - Initialization
  
  required init(dependencies: Dependencies) {
    self.dependencies = dependencies
    super.init()
    
    tableDataSource = ManageBookmarksTableViewDataSource(cellEditingDelegate: self)
    tableDelegate = ManageBookmarksTableViewDelegate()
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
  
  func disregardEvents() {
    disposeBag = DisposeBag()
  }
}

// MARK: - Observations

extension ManageBookmarksViewModel {

  func observeDataSource() {
    bookmarksInOrderObservable
      .map { $0.map {
        SettingsSingleLabelCellViewModel(dependencies: SettingsSingleLabelCellViewModel.Dependencies(
          labelText: $0.name,
          routingIntent: nil,
          editable: true,
          movable: true
        ))
      }}
      .map { [ManageBookmarksSection(sectionItems: $0)] }
      .bind { [weak tableDataSource] in tableDataSource?.sectionDataSources.accept($0) }
      .disposed(by: disposeBag)
    
    bookmarkedStationsCountObservable
      .filter { $0 == 0 }
      .take(1)
      .map { _ in ManageBookmarksStep.end }
      .bind(to: steps)
      .disposed(by: disposeBag)
  }
}

// MARK: - Delegate Extensions

extension ManageBookmarksViewModel: BaseTableViewDataSourceEditingDelegate {
  
  func didCommitEdit(with editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    guard editingStyle == .delete else {
      return
    }
    
    _ = bookmarksInOrderObservable
      .take(1)
      .asSingle()
      .map { $0[indexPath.row] }
      .flatMapCompletable(dependencies.weatherStationService.createRemoveBookmarkCompletable)
      .subscribe()
  }
  
  func didMoveRow(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    _ = bookmarksInOrderObservable
      .take(1)
      .asSingle()
      .map { bookmarks -> [WeatherStationDTO] in
        var mutableBookmarks = bookmarks
        let reorderedBookmark = mutableBookmarks.remove(at: sourceIndexPath.row)
        mutableBookmarks.insert(reorderedBookmark, at: destinationIndexPath.row)
        return mutableBookmarks
      }
      .map { bookmarks -> [Int: Int] in
        bookmarks.reduce([Int: Int]()) { partialResult, nextValue -> [Int: Int] in
          var mutablePartialResult = partialResult
          mutablePartialResult[nextValue.identifier] = bookmarks.firstIndex(of: nextValue)
          return mutablePartialResult
        }
      }
      .flatMapCompletable(dependencies.weatherStationService.createSetBookmarksSortingCompletable)
      .subscribe()
  }
}

// MARK: - Helpers

// MARK: - Helper Extensions
