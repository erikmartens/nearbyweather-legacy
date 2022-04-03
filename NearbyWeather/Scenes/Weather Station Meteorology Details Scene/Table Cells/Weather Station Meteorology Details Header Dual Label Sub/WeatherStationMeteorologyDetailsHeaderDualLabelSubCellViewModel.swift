//
//  WeatherStationMeteorologyDetailsHeaderDualLabelSubCellViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 02.04.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa

// MARK: - Dependencies

extension WeatherStationMeteorologyDetailsHeaderDualLabelSubCellViewModel {
  struct Dependencies {
    let lhsText: String
    let rhsText: String
    let isDayTime: Bool
  }
}

// MARK: - Class Definition

final class WeatherStationMeteorologyDetailsHeaderDualLabelSubCellViewModel: NSObject, BaseCellViewModel { // swiftlint:disable:this type_name
  
  let associatedCellReuseIdentifier = WeatherStationMeteorologyDetailsHeaderDualLabelSubCell.reuseIdentifier
  
  // MARK: - Properties
  
  private let dependencies: Dependencies

  // MARK: - Events
  
  lazy var cellModelDriver: Driver<WeatherStationMeteorologyDetailsHeaderDualLabelSubCellModel> = { [dependencies] in
    Self.createCellModelDriver(with: dependencies)
  }()

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

private extension WeatherStationMeteorologyDetailsHeaderDualLabelSubCellViewModel {
  
  static func createCellModelDriver(with dependencies: Dependencies) -> Driver<WeatherStationMeteorologyDetailsHeaderDualLabelSubCellModel> {
    Observable
      .just(
        WeatherStationMeteorologyDetailsHeaderDualLabelSubCellModel(
          lhsText: dependencies.lhsText,
          rhsText: dependencies.rhsText,
          backgroundColor: dependencies.isDayTime
          ? Constants.Theme.Color.ViewElement.WeatherInformation.colorBackgroundDay
          : Constants.Theme.Color.ViewElement.WeatherInformation.colorBackgroundNight
        )
      )
      .asDriver(onErrorJustReturn: WeatherStationMeteorologyDetailsHeaderDualLabelSubCellModel())
  }
}
