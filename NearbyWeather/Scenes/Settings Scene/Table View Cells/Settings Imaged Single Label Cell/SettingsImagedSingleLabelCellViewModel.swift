//
//  SettingsImagedSingleLabelCellViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 06.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa

// MARK: - Dependencies

extension SettingsImagedSingleLabelCellViewModel {
  struct Dependencies {
    let symbolImageBackgroundColor: UIColor
    let symbolImage: UIImage?
    let labelText: String
    let selectable: Bool
    let disclosable: Bool
  }
}

// MARK: - Class Definition

final class SettingsImagedSingleLabelCellViewModel: NSObject, BaseCellViewModel {
  
  let associatedCellReuseIdentifier = SettingsImagedSingleLabelCell.reuseIdentifier
  
  // MARK: - Properties
  
  private let dependencies: Dependencies

  // MARK: - Events
  
  lazy var cellModelDriver: Driver<SettingsImagedSingleLabelCellModel> = Self.createCellModelDriver(with: dependencies)

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

private extension SettingsImagedSingleLabelCellViewModel {
  
  static func createCellModelDriver(with dependencies: Dependencies) -> Driver<SettingsImagedSingleLabelCellModel> {
    Observable
      .just(SettingsImagedSingleLabelCellModel(
        symbolImageBackgroundColor: dependencies.symbolImageBackgroundColor,
        symbolImage: dependencies.symbolImage,
        labelText: dependencies.labelText,
        selectable: dependencies.selectable,
        disclosable: dependencies.disclosable
      ))
      .asDriver(onErrorJustReturn: SettingsImagedSingleLabelCellModel())
  }
}
