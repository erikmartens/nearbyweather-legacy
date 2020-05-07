//
//  ListWeatherInformationTableCellViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa

extension ListWeatherInformationTableCellViewModel {
  
  struct Dependencies {
    let weatherInformationIdentity: PersistencyModelIdentity
    let weatherInformationService: WeatherInformationService2
  }
}

final class ListWeatherInformationTableCellViewModel: NSObject, BaseCellViewModel {
  
  // MARK: - Properties
  
  private let dependencies: Dependencies

  // MARK: - Events
  
  let cellModelDriver: Driver<ListWeatherInformationTableCellModel>

  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
    
    self.cellModelDriver = Self.createDataSourceObserver(with: dependencies)
  }
}

// MARK: - Observations

private extension ListWeatherInformationTableCellViewModel {
  
  static func createDataSourceObserver(with dependencies: Dependencies) -> Driver<ListWeatherInformationTableCellModel> {
    dependencies.weatherInformationService
      .createBookmarkedWeatherInformationObservable(for: dependencies.weatherInformationIdentity.identifier)
      .map { $0?.entity }
      .map { weatherInformation -> ListWeatherInformationTableCellModel in
        ListWeatherInformationTableCellModel(
          weatherConditionCode: weatherInformation?.weatherCondition.first?.identifier,
          temperature: weatherInformation?.atmosphericInformation.temperatureKelvin,
          cloudCoverage: weatherInformation?.cloudCoverage.coverage,
          humidity: weatherInformation?.atmosphericInformation.humidity,
          windspeed: weatherInformation?.windInformation.windspeed
        )
      }
      .asDriver(onErrorJustReturn: ListWeatherInformationTableCellModel())
  }
}
