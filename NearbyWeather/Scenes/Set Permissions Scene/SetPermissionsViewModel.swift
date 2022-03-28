//
//  SetPermissionsViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 13.02.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa
import RxFlow
import CoreLocation

// MARK: - Dependencies

extension SetPermissionsViewModel {
  struct Dependencies {
    let userLocationService: UserLocationPermissionRequesting
  }
}

// MARK: - Class Definition

final class SetPermissionsViewModel: NSObject, Stepper, BaseViewModel {
  
  // MARK: - Routing
  
  let steps = PublishRelay<Step>()
  
  // MARK: - Assets
  
  private var disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  // MARK: - Events
  
  let onDidTapConfigureButtonSubject = PublishSubject<Void>()
  
  // MARK: - Drivers
  
  // MARK: - Observables
  
  // MARK: - Initialization
  
  required init(dependencies: Dependencies) {
    self.dependencies = dependencies
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
    observeUserInputEvents()
  }
  
  func disregardEvents() {
    disposeBag = DisposeBag()
  }
}

// MARK: - Observations

extension SetPermissionsViewModel {

  func observeUserInputEvents() {
    onDidTapConfigureButtonSubject
      .take(1)
      .asSingle()
      .flatMapCompletable { [dependencies] () in
        dependencies.userLocationService.requestWhenInUseLocationAccess()
      }
      .subscribe(onCompleted: { [unowned steps] in
        steps.accept(WelcomeStep.dismiss)
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - Delegate Extensions

// MARK: - Helpers

// MARK: - Helper Extensions
