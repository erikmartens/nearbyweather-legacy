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
    
  }
}

final class ListWeatherInformationTableCellViewModel: NSObject, BaseCellViewModel {
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  private let dependencies: Dependencies

  // MARK: - Events
  
  let cellModelSubject = PublishSubject<ListWeatherInformationTableCellModel>()

  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }

  // MARK: - Functions
  
  public func observeEvents() {
    observeDataSource()
    observeUserTapEvents()
  }
}

// MARK: - Observations

private extension ListWeatherInformationTableCellViewModel {
  
  func observeDataSource() {
    
  }
  
  func observeUserTapEvents() {
  
  }
}
