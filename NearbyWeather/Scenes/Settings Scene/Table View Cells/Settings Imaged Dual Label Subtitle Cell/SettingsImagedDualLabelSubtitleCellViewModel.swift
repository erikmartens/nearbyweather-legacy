//
//  SettingsImagedDualLabelSubtitleCellViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 20.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa
import RxFlow

// MARK: - Dependencies

extension SettingsImagedDualLabelSubtitleCellViewModel {
  struct Dependencies {
    let symbolImageBackgroundColor: UIColor
    let symbolImage: UIImage?
    let contentLabelText: String
    let descriptionLabelTextObservable: Observable<String>
    let selectable: Bool
    let disclosable: Bool
    let routingIntent: Step?
  }
}

// MARK: - Class Definition

final class SettingsImagedDualLabelSubtitleCellViewModel: NSObject, BaseCellViewModel {
  
  let associatedCellReuseIdentifier = SettingsImagedDualLabelSubtitleCell.reuseIdentifier
  lazy var onSelectedRoutingIntent: Step? = {
    dependencies.routingIntent
  }()
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  private let dependencies: Dependencies

  // MARK: - Events
  
  // MARK: - Observables
  
  private lazy var cellModelRelay: BehaviorRelay<SettingsImagedDualLabelSubtitleCellModel> = Self.createCellModelRelay(with: dependencies)
  
  // MARK: - Drivers
  
  lazy var cellModelDriver: Driver<SettingsImagedDualLabelSubtitleCellModel> = cellModelRelay.asDriver(onErrorJustReturn: SettingsImagedDualLabelSubtitleCellModel())

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

extension SettingsImagedDualLabelSubtitleCellViewModel {
  
  func observeDataSource() {
    dependencies.descriptionLabelTextObservable
      .map { [dependencies] descriptionText -> SettingsImagedDualLabelSubtitleCellModel in
        SettingsImagedDualLabelSubtitleCellModel(
          symbolImageBackgroundColor: dependencies.symbolImageBackgroundColor,
          symbolImage: dependencies.symbolImage,
          contentLabelText: dependencies.contentLabelText,
          descriptionLabelText: descriptionText,
          selectable: dependencies.selectable,
          disclosable: dependencies.disclosable
        )
      }
      .bind(to: cellModelRelay)
      .disposed(by: disposeBag)
  }
}

// MARK: - Observation Helpers

private extension SettingsImagedDualLabelSubtitleCellViewModel {
  
  static func createCellModelRelay(with dependencies: Dependencies) -> BehaviorRelay<SettingsImagedDualLabelSubtitleCellModel> {
    BehaviorRelay<SettingsImagedDualLabelSubtitleCellModel>(
      value: SettingsImagedDualLabelSubtitleCellModel(
        symbolImageBackgroundColor: dependencies.symbolImageBackgroundColor,
        symbolImage: dependencies.symbolImage,
        contentLabelText: dependencies.contentLabelText,
        descriptionLabelText: nil, // start with default value
        selectable: dependencies.selectable,
        disclosable: dependencies.disclosable
      )
    )
  }
}
