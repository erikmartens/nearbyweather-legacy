//
//  SetApiKeyViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.02.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa
import RxFlow
import CoreLocation

// MARK: - Dependencies

extension SetApiKeyViewModel {
  struct Dependencies {
    let apiKeyService: ApiKeyReading & ApiKeySetting
  }
}

// MARK: - Class Definition

final class SetApiKeyViewModel: NSObject, Stepper, BaseViewModel {
  
  // MARK: - Routing
  
  let steps = PublishRelay<Step>()
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  var textFieldDelegate: UITextFieldDelegate? // swiftlint:disable:this weak_delegate
  
  // MARK: - Events
  
  let onDidTapSaveButtonSubject = PublishSubject<Void>()
  let onDidTapInstructionButtonSubject = PublishSubject<Void>()
  
  let apiInputTextFieldRelay = BehaviorRelay<String?>(value: nil)
  
  // MARK: - Drivers
  
  lazy var isSaveButtonActiveDriver: Driver<Bool> = { [unowned apiInputTextFieldRelay] in
    apiInputTextFieldRelay
      .asObservable()
      .map { text in
        guard let text = text else {
          return false
        }
        return text.count == 32
      }
      .asDriver(onErrorJustReturn: false)
  }()
  
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

extension SetApiKeyViewModel {

  func observeDataSource() {
    // nothing to do
  }
  
  func observeUserInputEvents() {
    
    let apiTextFieldTextObservable = apiInputTextFieldRelay
      .debounce(.milliseconds(200), scheduler: MainScheduler.instance)
      .distinctUntilChanged()
      .asObservable()
      .share(replay: 1)
    
    let shouldSaveApiKeyObservable = onDidTapSaveButtonSubject
      .asObservable()
      .flatMapLatest { [apiTextFieldTextObservable] () -> Observable<String?> in apiTextFieldTextObservable }
      .filterNil()
      .filter { $0.count == 32 }

    _ = shouldSaveApiKeyObservable
      .take(1)
      .asSingle()
      .flatMapCompletable { [dependencies] apiKey in
        dependencies.apiKeyService.createSetApiKeyCompletable(apiKey)
      }
      .subscribe(onCompleted: { [unowned steps] in
        steps.accept(WelcomeStep.setPermissions)
      })
    
    onDidTapInstructionButtonSubject
      .asObservable()
      .subscribe(onNext: { [unowned steps] () in
        steps.accept(WelcomeStep.apiInstructions)
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - Delegate Extensions

// MARK: - Helpers

// MARK: - Helper Extensions
