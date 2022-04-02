//
//  LoadingViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 13.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa
import RxFlow

// MARK: - Dependencies

extension LoadingViewModel {
  
  struct Dependencies {
    let title: String
  }
}

// MARK: - Class Definition

final class LoadingViewModel: NSObject, Stepper, BaseViewModel {
  
  // MARK: - Routing
  
  let steps = PublishRelay<Step>()
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  // MARK: - Events
  
  // MARK: - Drivers
  
  lazy var titleDriver: Driver<String?> = Observable.just(dependencies.title).asDriver(onErrorJustReturn: nil)
  
  // MARK: - Observables
  
  // MARK: - Initialization
  
  required init(dependencies: Dependencies) {
    self.dependencies = dependencies
    super.init()
  }
  
  deinit {
    printDebugMessage(
      domain: String(describing: self),
      message: "was deinitialized",
      type: .info
    )
  }
  
  // MARK: - Functions
  
  func observeEvents() {
    observeDataSource()
    observeUserTapEvents()
  }
}

// MARK: - Observations
