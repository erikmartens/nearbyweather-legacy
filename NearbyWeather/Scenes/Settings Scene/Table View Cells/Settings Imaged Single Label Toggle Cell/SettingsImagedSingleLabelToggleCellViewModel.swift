//
//  SettingsImagedSingleLabelToggleCellViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 06.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa

// MARK: - Dependencies

extension SettingsImagedSingleLabelToggleCellViewModel {
  struct Dependencies {
    let symbolImageBackgroundColor: UIColor
    let symbolImage: UIImage?
    let labelText: String
    let isToggleOnObservable: Observable<Bool>
    let didFlipToggleSwitchSubject: PublishSubject<Bool>
  }
}

// MARK: - Class Definition

final class SettingsImagedSingleLabelToggleCellViewModel: NSObject, BaseCellViewModel {
  
  let associatedCellReuseIdentifier = SettingsImagedSingleLabelToggleCell.reuseIdentifier
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  private let dependencies: Dependencies

  // MARK: - Events
  
  let onDidFlipToggleSwitchSubject = PublishSubject<Bool>()
  
  // MARK: - Observables
  
  private lazy var cellModelRelay: BehaviorRelay<SettingsImagedSingleLabelToggleCellModel> = Self.createCellModelRelay(with: dependencies)
  
  // MARK: - Drivers
  
  lazy var cellModelDriver: Driver<SettingsImagedSingleLabelToggleCellModel> = cellModelRelay.asDriver(onErrorJustReturn: SettingsImagedSingleLabelToggleCellModel())

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

extension SettingsImagedSingleLabelToggleCellViewModel {
  
  func observeDataSource() {
    dependencies.isToggleOnObservable
      .map { [dependencies] isToggleOn -> SettingsImagedSingleLabelToggleCellModel in
        SettingsImagedSingleLabelToggleCellModel(
          symbolImageBackgroundColor: dependencies.symbolImageBackgroundColor,
          symbolImage: dependencies.symbolImage,
          labelText: dependencies.labelText,
          isToggleOn: isToggleOn
        )
      }
      .bind(to: cellModelRelay)
      .disposed(by: disposeBag)
  }
  
  func observeUserTapEvents() {
    onDidFlipToggleSwitchSubject
      .bind(to: dependencies.didFlipToggleSwitchSubject)
      .disposed(by: disposeBag)
  }
}

// MARK: - Observation Helpers

private extension SettingsImagedSingleLabelToggleCellViewModel {
  
  static func createCellModelRelay(with dependencies: Dependencies) -> BehaviorRelay<SettingsImagedSingleLabelToggleCellModel> {
    BehaviorRelay<SettingsImagedSingleLabelToggleCellModel>(
      value: SettingsImagedSingleLabelToggleCellModel(
        symbolImageBackgroundColor: dependencies.symbolImageBackgroundColor,
        symbolImage: dependencies.symbolImage,
        labelText: dependencies.labelText,
        isToggleOn: false // start with default value
      )
    )
  }
}
