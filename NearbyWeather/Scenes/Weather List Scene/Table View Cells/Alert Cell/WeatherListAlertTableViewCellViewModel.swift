//
//  WeatherInformationAlertTableViewCellViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 05.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa

// MARK: - Dependencies

extension WeatherListAlertTableViewCellViewModel {
  struct Dependencies {
    let title: String
    let description: String
  }
}

// MARK: - Class Definition

final class WeatherListAlertTableViewCellViewModel: NSObject, BaseCellViewModel {
  
  let associatedCellReuseIdentifier = WeatherListAlertTableViewCell.reuseIdentifier

  // MARK: - Events
  
  lazy var cellModelDriver: Driver<WeatherListAlertTableViewCellModel> = Self.createCellModelDriver(dependencies: dependencies)
  
  // MARK: - Properties
  
  let dependencies: Dependencies

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

private extension WeatherListAlertTableViewCellViewModel {
  
  static func createCellModelDriver(dependencies: Dependencies) -> Driver<WeatherListAlertTableViewCellModel> {
    Observable
      .just(WeatherListAlertTableViewCellModel(
        alertTitle: dependencies.title,
        alertDescription: dependencies.description
      ))
      .asDriver(onErrorJustReturn: WeatherListAlertTableViewCellModel())
//    var errorMessage: String
//
//    if let error = error as? WeatherInformationService.DomainError {
//      switch error {
//      case .nearbyWeatherInformationMissing:
//        errorMessage = R.string.localizable.empty_nearby_locations_message()
//      case .bookmarkedWeatherInformationMissing:
//        errorMessage = R.string.localizable.empty_bookmarks_message()
//      }
//    } else if let error = error as? UserLocationService.DomainError {
//      switch error {
//      case .locationAuthorizationError:
//        errorMessage = R.string.localizable.location_denied_error()
//      case .locationUndeterminableError:
//        errorMessage = R.string.localizable.location_unavailable_error()
//      }
//    } else if let error = error as? ApiKeyService.DomainError {
//      switch error {
//      case .apiKeyMissingError:
//        errorMessage = R.string.localizable.missing_api_key_error()
//      case .apiKeyInvalidError:
//        errorMessage = R.string.localizable.unauthorized_api_key_error()
//      }
//    } else {
//      errorMessage = R.string.localizable.unknown_error()
//    }
//
//    let cellModel = WeatherListAlertTableViewCellModel(alertInformationText: errorMessage)
//
//    return Observable
//      .just(cellModel)
//      .asDriver(onErrorJustReturn: cellModel)
  }
}
