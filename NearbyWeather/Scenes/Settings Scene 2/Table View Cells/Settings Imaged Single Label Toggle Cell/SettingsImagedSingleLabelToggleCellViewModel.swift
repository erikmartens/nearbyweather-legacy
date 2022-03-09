//
//  SettingsImagedSingleLabelToggleCellViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 06.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa

// MARK: - Dependencies

extension SettingsImagedSingleLabelToggleCellViewModel {
  struct Dependencies {
    let symbolImageBackgroundColor: UIColor
    let symbolImage: UIImage?
    let labelText: String
    let isToggleOnObservable: Observable<Bool>
  }
}

// MARK: - Class Definition

final class SettingsImagedSingleLabelToggleCellViewModel: NSObject, BaseCellViewModel {
  
  // MARK: - Properties
  
  private let dependencies: Dependencies

  // MARK: - Events
  
  lazy var cellModelDriver: Driver<SettingsImagedSingleLabelToggleCellModel> = Self.createCellModelDriver(with: dependencies)

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

private extension SettingsImagedSingleLabelToggleCellViewModel {
  
  static func createCellModelDriver(with dependencies: Dependencies) -> Driver<SettingsImagedSingleLabelToggleCellModel> {
    Observable
      .combineLatest(
        Observable.just(dependencies.symbolImageBackgroundColor),
        Observable.just(dependencies.symbolImage),
        Observable.just(dependencies.labelText),
        dependencies.isToggleOnObservable,
        resultSelector: SettingsImagedSingleLabelToggleCellModel.init
      )
      .asDriver(onErrorJustReturn: SettingsImagedSingleLabelToggleCellModel())
  }
}
