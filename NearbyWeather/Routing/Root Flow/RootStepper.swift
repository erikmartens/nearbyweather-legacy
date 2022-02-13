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
  case main
  case welcome
  case dimissWelcome
}

// MARK: - Dependencies

extension RootStepper {
  struct Dependencies {
    let apiKeyService: ApiKeyReading
  }
}

// MARK: - Class Definition

class RootStepper: Stepper {
  
  var steps = PublishRelay<Step>()
  
  // TODO: make initial step that shows a loading screen while the app is loading its content
  
  // MARK: - Assets
  
  let disposeBag = DisposeBag()
  
  let dependencies: Dependencies
  
  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }
  
  // MARK: - Functions
  
  func readyToEmitSteps() {
    createRootSceneStateStepObservable
      .take(1)
      .asSingle()
      .subscribe(onSuccess: { [unowned steps] in steps.accept($0) })
      .disposed(by: disposeBag)
  }
}

// MARK: - Helper Extensions

private extension RootStepper {
  
  var createRootSceneStateStepObservable: Observable<Step> {
    dependencies.apiKeyService
      .createApiKeyIsValidObservable()
      .distinctUntilChanged()
      .map {
        $0 == .missing ? RootStep.welcome : RootStep.main
      }
  }
}
