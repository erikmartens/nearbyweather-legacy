//
//  SettingsTextEntryCellViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa

// MARK: - Dependencies

extension SettingsTextEntryCellViewModel {
  struct Dependencies {
    let textFieldPlaceholderText: String
    let textFieldTextSubject: PublishRelay<String?>
  }
}

// MARK: - Class Definition

final class SettingsTextEntryCellViewModel: NSObject, BaseCellViewModel {
  
  // MARK: - Properties
  
  private let dependencies: Dependencies

  // MARK: - Events
  
  lazy var textFieldTextSubject = dependencies.textFieldTextSubject
  
  // MARK: - Drivers
  
  lazy var cellModelDriver: Driver<SettingsTextEntryCellModel> = Self.createCellModelDriver(with: dependencies)

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

private extension SettingsTextEntryCellViewModel {
  
  static func createCellModelDriver(with dependencies: Dependencies) -> Driver<SettingsTextEntryCellModel> {
    Observable
      .combineLatest(
        Observable.just(dependencies.textFieldPlaceholderText),
        dependencies.textFieldTextSubject.asObservable(),
        resultSelector: SettingsTextEntryCellModel.init
      )
      .asDriver(onErrorJustReturn: SettingsTextEntryCellModel())
  }
}
