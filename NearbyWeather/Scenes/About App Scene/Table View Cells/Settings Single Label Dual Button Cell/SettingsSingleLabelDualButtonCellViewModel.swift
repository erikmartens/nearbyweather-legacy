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
    let didTapLhsButtonSubject: PublishSubject<Void>
    let didTapRhsButtonSubject: PublishSubject<Void>
  }
}

// MARK: - Class Definition

final class SettingsSingleLabelDualButtonCellViewModel: NSObject, BaseCellViewModel {
  
  let associatedCellReuseIdentifier = SettingsSingleLabelDualButtonCell.reuseIdentifier
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  // MARK: - Events
  
  let didTapLhsButtonSubject = PublishSubject<Void>()
  let didTapRhsButtonSubject = PublishSubject<Void>()
  
  // MARK: - Drivers
  
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

extension SettingsSingleLabelDualButtonCellViewModel {
  
  func observeUserTapEvents() {
    didTapLhsButtonSubject
      .bind(to: dependencies.didTapLhsButtonSubject)
      .disposed(by: disposeBag)
    
    didTapRhsButtonSubject
      .bind(to: dependencies.didTapRhsButtonSubject)
      .disposed(by: disposeBag)
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
