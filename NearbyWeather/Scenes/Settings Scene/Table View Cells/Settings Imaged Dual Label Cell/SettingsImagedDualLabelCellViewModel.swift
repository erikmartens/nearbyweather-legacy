//
//  SettingsImagedDualLabelCellViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 06.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa

// MARK: - Dependencies

extension SettingsImagedDualLabelCellViewModel {
  struct Dependencies {
    let symbolImageBackgroundColor: UIColor
    let symbolImage: UIImage?
    let contentLabelText: String
    let descriptionLabelTextObservable: Observable<String>
    let selectable: Bool
    let disclosable: Bool
  }
}

// MARK: - Class Definition

final class SettingsImagedDualLabelCellViewModel: NSObject, BaseCellViewModel {
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  private let dependencies: Dependencies

  // MARK: - Events
  
  // MARK: - Observables
  
  private lazy var cellModelRelay: BehaviorRelay<SettingsImagedDualLabelCellModel> = Self.createCellModelRelay(with: dependencies)
  
  // MARK: - Drivers
  
  lazy var cellModelDriver: Driver<SettingsImagedDualLabelCellModel> = cellModelRelay.asDriver(onErrorJustReturn: SettingsImagedDualLabelCellModel())

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

extension SettingsImagedDualLabelCellViewModel {
  
  func observeDataSource() {
    dependencies.descriptionLabelTextObservable
      .map { [dependencies] descriptionText -> SettingsImagedDualLabelCellModel in
        SettingsImagedDualLabelCellModel(
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

private extension SettingsImagedDualLabelCellViewModel {
  
  static func createCellModelRelay(with dependencies: Dependencies) -> BehaviorRelay<SettingsImagedDualLabelCellModel> {
    BehaviorRelay<SettingsImagedDualLabelCellModel>(
      value: SettingsImagedDualLabelCellModel(
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
