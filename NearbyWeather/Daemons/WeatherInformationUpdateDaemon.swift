//
//  WeatherInformationUpdateDaemon.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 13.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

//
//  ApiKeyService2.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 07.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxAlamofire

// MARK: - Domain-Specific Errors

extension WeatherInformationUpdateDaemon {
  enum DomainError: String, Error {
    var domain: String { "WeatherInformationService" }
    
    case serviceWasDeallocatedError = "Trying to use a service-dependency, however the service was unexpectedly nil."
  }
}

// MARK: - Dependencies

extension WeatherInformationUpdateDaemon {
  struct Dependencies {
    weak var weatherStationService: WeatherStationService2?
    weak var weatherInformationService: WeatherInformationService2?
  }
}

// MARK: - Class Definition

final class WeatherInformationUpdateDaemon {
  
  // MARK: - Assets
  
  let disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
    startObservations()
  }
  
  // MARK: - Functions
  
  private func startObservations() {
    observeBookmarkedStationsChanges()
  }
}

// MARK: - Observations

private extension WeatherInformationUpdateDaemon {
  
  func observeBookmarkedStationsChanges() {
    dependencies.weatherStationService?
      .createGetBookmarkedStationsObservable()
      .distinctUntilChanged()
      .flatMapLatest { [dependencies] _ -> Observable<Event<Void>> in
        guard let updateEvent = dependencies.weatherInformationService?
                .createUpdateBookmarkedWeatherInformationCompletable()
                .asObservable()
                .map({ _ in () })
                .materialize()
        else {
          throw DomainError.serviceWasDeallocatedError
        }
        return updateEvent
      }
      .filter {
        switch $0 {
        case .next():
          return true
        case .error(_), .completed:
          return false
        }
      }
      .subscribe()
      .disposed(by: disposeBag)
  }
}
