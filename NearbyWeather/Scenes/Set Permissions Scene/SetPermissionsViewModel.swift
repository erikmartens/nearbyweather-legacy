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
    let userLocationService: UserLocationPermissionRequesting & UserLocationPermissionReading
    let weatherInformationService: WeatherInformationUpdating
    let applicationCycleService: ApplicationStateSetting
  }
}

// MARK: - Class Definition

final class SetPermissionsViewModel: NSObject, Stepper, BaseViewModel {
  
  // MARK: - Routing
  
  let steps = PublishRelay<Step>()
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  
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
}

// MARK: - Observations

extension SetPermissionsViewModel {

  func observeUserInputEvents() {
    _ = onDidTapConfigureButtonSubject
      .asObservable()
      .flatMapLatest { [unowned self] _ in
        dependencies.userLocationService
          .requestWhenInUseLocationAccess()
          .asObservable()
          .materialize()
      }
      .subscribe()
    
    _ = dependencies.userLocationService
      .createUserDidDecideLocationAccessAuthorizationCompletable()
      .andThen(dependencies.applicationCycleService.createSetSetupCompletedCompletable(SetupCompletedModel(completed: true)))
      .andThen(dependencies.weatherInformationService.createUpdateNearbyWeatherInformationCompletable())
      .subscribe(onCompleted: { [unowned self] in
        steps.accept(WelcomeStep.dismiss)
      })
  }
}

// MARK: - Delegate Extensions

// MARK: - Helpers

// MARK: - Helper Extensions
