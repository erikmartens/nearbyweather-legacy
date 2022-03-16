//
//  SettingsDualLabelSubtitleCellViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa
import RxFlow

// MARK: - Dependencies

extension SettingsDualLabelSubtitleCellViewModel {
  struct Dependencies {
    let contentLabelText: String
    let subtitleLabelText: String
    let selectable: Bool
    let disclosable: Bool
    let routingIntent: Step?
  }
}

// MARK: - Class Definition

final class SettingsDualLabelSubtitleCellViewModel: NSObject, BaseCellViewModel {
  
  let associatedCellReuseIdentifier = SettingsDualLabelSubtitleCell.reuseIdentifier
  lazy var onSelectedRoutingIntent: Step? = {
    dependencies.routingIntent
  }()
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  // MARK: - Events
  
  lazy var cellModelDriver: Driver<SettingsDualLabelSubtitleCellModel> = Self.createCellModelDriver(with: dependencies)
  
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

private extension SettingsDualLabelSubtitleCellViewModel {
  
  static func createCellModelDriver(with dependencies: Dependencies) -> Driver<SettingsDualLabelSubtitleCellModel> {
    Observable
      .just(SettingsDualLabelSubtitleCellModel(
        contentLabelText: dependencies.contentLabelText,
        subtitleLabelText: dependencies.subtitleLabelText,
        selectable: dependencies.selectable,
        disclosable: dependencies.disclosable
      ))
      .asDriver(onErrorJustReturn: SettingsDualLabelSubtitleCellModel())
  }
}
