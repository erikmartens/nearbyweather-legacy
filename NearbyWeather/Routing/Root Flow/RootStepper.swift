//
//  RootStepper.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxFlow
import RxCocoa
import RxSwift

enum RootStep: Step {
  case loading
  case welcome
  case main
  case dimissWelcome
}

// MARK: - Dependencies

extension RootStepper {
  struct Dependencies {
    let applicationCycleService: ApplicationStateReading
    let migrationRunningObservable: Observable<Bool>
  }
}

// MARK: - Class Definition

class RootStepper: Stepper {
  
  var steps = PublishRelay<Step>()
  var initialStep: Step = RootStep.loading
  
  // MARK: - Assets
  
  let disposeBag = DisposeBag()
  
  let dependencies: Dependencies
  
  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }
  
  // MARK: - Functions
  
  func readyToEmitSteps() {
    dependencies.migrationRunningObservable
      .skip { $0 == true }
      .flatMapLatest { [unowned self] _ in
        dependencies.applicationCycleService.createGetSetupCompletedObservable()
      }
      .take(1)
      .asSingle()
      .map { ($0?.completed ?? false) == true ? RootStep.main : RootStep.welcome }
      .subscribe(onSuccess: steps.accept)
      .disposed(by: disposeBag)
  }
}
