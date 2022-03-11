//
//  SettingsSingleLabelDualButtonCellViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa

// MARK: - Dependencies

extension SettingsSingleLabelDualButtonCellViewModel {
  struct Dependencies {
    let contentLabelText: String
    let lhsButtonTitleText: String
    let rhsButtonTitleText: String
  }
}

// MARK: - Class Definition

final class SettingsSingleLabelDualButtonCellViewModel: NSObject, BaseCellViewModel {
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  // MARK: - Events
  
  lazy var cellModelDriver: Driver<SettingsSingleLabelDualButtonCellModel> = Self.createCellModelDriver(with: dependencies)
  
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

private extension SettingsSingleLabelDualButtonCellViewModel {
  
  static func createCellModelDriver(with dependencies: Dependencies) -> Driver<SettingsSingleLabelDualButtonCellModel> {
    Observable
      .just(SettingsSingleLabelDualButtonCellModel(
        contentLabelText: dependencies.contentLabelText,
        lhsButtonTitle: dependencies.lhsButtonTitleText,
        rhsButtonTitle: dependencies.rhsButtonTitleText
      ))
      .asDriver(onErrorJustReturn: SettingsSingleLabelDualButtonCellModel())
  }
}
