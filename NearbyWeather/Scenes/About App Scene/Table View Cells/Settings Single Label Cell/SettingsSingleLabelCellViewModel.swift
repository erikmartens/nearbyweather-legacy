//
//  SettingsSingleLabelCellViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa

// MARK: - Dependencies

extension SettingsSingleLabelCellViewModel {
  struct Dependencies {
    let labelText: String
    let selectable: Bool
    let disclosable: Bool
  }
}

// MARK: - Class Definition

final class SettingsSingleLabelCellViewModel: NSObject, BaseCellViewModel {
  
  // MARK: - Properties
  
  private let dependencies: Dependencies

  // MARK: - Events
  
  lazy var cellModelDriver: Driver<SettingsSingleLabelCellModel> = Self.createCellModelDriver(with: dependencies)

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

private extension SettingsSingleLabelCellViewModel {
  
  static func createCellModelDriver(with dependencies: Dependencies) -> Driver<SettingsSingleLabelCellModel> {
    Observable
      .just(SettingsSingleLabelCellModel(
        labelText: dependencies.labelText,
        selectable: dependencies.selectable,
        disclosable: dependencies.disclosable
      ))
      .asDriver(onErrorJustReturn: SettingsSingleLabelCellModel())
  }
}
