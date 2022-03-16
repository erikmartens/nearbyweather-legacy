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
    let editable: Bool
    let movable: Bool
    
    init(
      labelText: String,
      selectable: Bool = false,
      disclosable: Bool = false,
      editable: Bool = false,
      movable: Bool = false
    ) {
      self.labelText = labelText
      self.selectable = selectable
      self.disclosable = disclosable
      self.editable = editable
      self.movable = movable
    }
  }
}

// MARK: - Class Definition

final class SettingsSingleLabelCellViewModel: NSObject, BaseCellViewModel {

  let associatedCellReuseIdentifier = SettingsSingleLabelCell.reuseIdentifier
  
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
  
  var canEditRow: Bool { dependencies.editable }

  var canMoveRow: Bool { dependencies.movable }
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
