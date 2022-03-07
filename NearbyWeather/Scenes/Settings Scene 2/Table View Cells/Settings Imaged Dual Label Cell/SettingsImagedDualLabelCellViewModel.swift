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
    let symbolImage: UIImage
    let contentLabelText: String
    let descriptionLabelTextObservable: Observable<String>
    let selectable: Bool
    let disclosable: Bool
  }
}

// MARK: - Class Definition

final class SettingsImagedDualLabelCellViewModel: NSObject, BaseCellViewModel {
  
  // MARK: - Properties
  
  private let dependencies: Dependencies

  // MARK: - Events
  
  lazy var cellModelDriver: Driver<SettingsImagedDualLabelCellModel> = Self.createCellModelDriver(with: dependencies)

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

private extension SettingsImagedDualLabelCellViewModel {
  
  static func createCellModelDriver(with dependencies: Dependencies) -> Driver<SettingsImagedDualLabelCellModel> {
    Observable
      .combineLatest(
        Observable.just(dependencies.symbolImageBackgroundColor),
        Observable.just(dependencies.symbolImage),
        Observable.just(dependencies.contentLabelText),
        dependencies.descriptionLabelTextObservable,
        Observable.just(dependencies.selectable),
        Observable.just(dependencies.disclosable),
        resultSelector: SettingsImagedDualLabelCellModel.init
      )
      .asDriver(onErrorJustReturn: SettingsImagedDualLabelCellModel())
  }
}
