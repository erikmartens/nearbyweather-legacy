//
//  SettingsAppVersionCellViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa

// MARK: - Dependencies

extension SettingsAppVersionCellViewModel {
  struct Dependencies {
    let appIconImageObseravble: Observable<UIImage?>
    let appNameTitle: String
    let appVersionTitle: String
  }
}

// MARK: - Class Definition

final class SettingsAppVersionCellViewModel: NSObject, BaseCellViewModel {
  
  let associatedCellReuseIdentifier = SettingsAppVersionCell.reuseIdentifier
  
  // MARK: - Properties
  
  private let dependencies: Dependencies

  // MARK: - Events
  
  lazy var cellModelDriver: Driver<SettingsAppVersionCellModel> = Self.createCellModelDriver(with: dependencies)

  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }
  
  // MARK: - Functions
  
  func observeEvents() {
    observeDataSource()
    observeUserTapEvents()
  }
}

// MARK: - Observation Helpers

private extension SettingsAppVersionCellViewModel {
  
  static func createCellModelDriver(with dependencies: Dependencies) -> Driver<SettingsAppVersionCellModel> {
    Observable
      .combineLatest(
        dependencies.appIconImageObseravble,
        Observable.just(dependencies.appNameTitle),
        Observable.just(dependencies.appVersionTitle),
        resultSelector: SettingsAppVersionCellModel.init)
      .asDriver(onErrorJustReturn: SettingsAppVersionCellModel())
  }
}
