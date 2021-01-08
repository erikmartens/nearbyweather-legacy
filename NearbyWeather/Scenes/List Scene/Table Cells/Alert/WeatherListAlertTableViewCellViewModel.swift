//
//  WeatherInformationAlertTableViewCellViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 05.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa

extension WeatherListAlertTableViewCellViewModel {
  
  struct Dependencies {
    let error: Error
  }
}

final class WeatherListAlertTableViewCellViewModel: NSObject, BaseCellViewModel {

  // MARK: - Events
  
  let cellModelDriver: Driver<WeatherListAlertTableViewCellModel>
  
  // MARK: - Properties
  
  let dependencies: Dependencies

  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
    cellModelDriver = Self.createDataSourceObserver(error: dependencies.error)
  }
}

// MARK: - Observations

private extension WeatherListAlertTableViewCellViewModel {
  
  static func createDataSourceObserver(error: Error) -> Driver<WeatherListAlertTableViewCellModel> {
    var errorMessage: String
    
    if let error = error as? UserLocationService2.DomainError {
      switch error {
      case .authorizationError:
        errorMessage = R.string.localizable.location_denied_error()
      case .locationUndeterminableError:
        errorMessage = R.string.localizable.location_unavailable_error()
      }
    } else if let error = error as? ApiKeyService2.DomainError {
      switch error {
      case .apiKeyMissingError:
        errorMessage = R.string.localizable.missing_api_key_error()
      case .apiKeyInvalidError:
        errorMessage = R.string.localizable.unauthorized_api_key_error()
      }
    } else {
      errorMessage = R.string.localizable.unknown_error()
    }
    
    let cellModel = WeatherListAlertTableViewCellModel(alertInformationText: errorMessage)
    
    return Observable
      .just(cellModel)
      .asDriver(onErrorJustReturn: cellModel)
  }
}
