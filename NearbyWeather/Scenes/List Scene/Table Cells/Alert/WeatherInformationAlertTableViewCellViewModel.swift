//
//  WeatherInformationAlertTableViewCellViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 05.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa

extension WeatherInformationAlertTableViewCellViewModel {
  
  struct Dependencies {
    let alertInformationIdentity: PersistencyModelIdentityProtocol
  }
}

final class WeatherInformationAlertTableViewCellViewModel: NSObject, BaseCellViewModel {
  
  // MARK: - Public Access
  
  var alertInformationIdentity: PersistencyModelIdentityProtocol {
    dependencies.alertInformationIdentity
  }
  
  // MARK: - Properties
  
  private let dependencies: Dependencies

  // MARK: - Events
  
  let cellModelDriver: Driver<WeatherInformationAlertTableViewCellModel>

  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
    cellModelDriver = Self.createDataSourceObserver(with: dependencies)
  }
}

// MARK: - Observations

private extension WeatherInformationAlertTableViewCellViewModel {
  
  static func createDataSourceObserver(with dependencies: Dependencies) -> Driver<WeatherInformationAlertTableViewCellModel> {
   Observable
      .just(WeatherInformationAlertTableViewCellModel())
      .asDriver(onErrorJustReturn: WeatherInformationAlertTableViewCellModel())
  }
}
