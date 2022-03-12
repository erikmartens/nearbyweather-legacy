//
//  ApiKeyInputViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa
import RxFlow

// MARK: - Dependencies

extension ApiKeyInputViewModel {
  struct Dependencies {
    let apiKeyService: ApiKeyReading & ApiKeySetting
  }
}

// MARK: - Class Definition

final class ApiKeyInputViewModel: NSObject, Stepper, BaseViewModel {
  
  // MARK: - Routing
  
  let steps = PublishRelay<Step>()
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  var tableDelegate: AboutAppTableViewDelegate? // swiftlint:disable:this weak_delegate
  let tableDataSource: AboutAppTableViewDataSource
  
  // MARK: - Events
  
  let onDidTapSaveBarButtonSubject = PublishSubject<Void>()
  let inputTextFieldTextSubject = PublishRelay<String?>()
  private let saveBarButtonIsEnabledSubject = PublishSubject<Bool>()
  
  // MARK: - Drivers
  
  lazy var saveBarButtonIsEnabledDriver = saveBarButtonIsEnabledSubject.asDriver(onErrorJustReturn: false)
  
  // MARK: - Observables
  
  // MARK: - Initialization
  
  required init(dependencies: Dependencies) {
    self.dependencies = dependencies
    tableDataSource = AboutAppTableViewDataSource()
    super.init()
    
    tableDelegate = AboutAppTableViewDelegate(cellSelectionDelegate: self)
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

extension ApiKeyInputViewModel {

  func observeDataSource() {
    dependencies.apiKeyService
      .createGetApiKeyObservable()
      .map { apiKey -> String? in apiKey } // convert to optional
      .catch { error in
        guard let error = error as? ApiKeyService2.DomainError else {
          throw error
        }
        switch error {
        case .apiKeyMissingError:
          return Observable.just(nil)
        case let .apiKeyInvalidError(invalidApiKey):
          return Observable.just(invalidApiKey)
        }
      }
      .bind(to: inputTextFieldTextSubject)
      .disposed(by: disposeBag)
    
    // API Key Entry Section
    let apiKeyEntrySectionItems: [BaseCellViewModelProtocol] = [
      SettingsTextEntryCellViewModel(dependencies: SettingsTextEntryCellViewModel.Dependencies(
        textFieldPlaceholderText: R.string.localizable.apiKey(),
        textFieldTextSubject: inputTextFieldTextSubject
      ))
    ]
    
    let apiKeyEntrySectionObservable = Observable.just(ApiKeyInputTextEntrySection(sectionItems: apiKeyEntrySectionItems))
    
    apiKeyEntrySectionObservable
      .map { [$0] }
      .bind { [weak tableDataSource] in tableDataSource?.sectionDataSources.accept($0) }
      .disposed(by: disposeBag)
  }
  
  func observeUserTapEvents() {
    inputTextFieldTextSubject
      .map { ($0?.count ?? 0) == Constants.Values.ApiKey.kOpenWeatherMapApiKeyLength }
      .bind(to: saveBarButtonIsEnabledSubject)
      .disposed(by: disposeBag)
    
    onDidTapSaveBarButtonSubject
      .withLatestFrom(inputTextFieldTextSubject)
      .filterNil()
      .filter { $0.count == Constants.Values.ApiKey.kOpenWeatherMapApiKeyLength }
      .do(onNext: { [dependencies] newApiKey in
        _ = dependencies.apiKeyService.createSetApiKeyCompletable(newApiKey).subscribe()
      })
      .map { _ in ApiKeyInputStep.end }
      .bind(to: steps)
      .disposed(by: disposeBag)
  }
}

// MARK: - Delegate Extensions

extension ApiKeyInputViewModel: BaseTableViewSelectionDelegate {
  
  func didSelectRow(at indexPath: IndexPath) {
    // nothing to do
  }
}

// MARK: - Helpers

// MARK: - Helper Extensions
