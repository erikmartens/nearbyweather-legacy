//
//  ListTypeSelectionViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa
import RxFlow

extension ListTypeSelectionViewModel {
  struct Dependencies {
    let preferencesService: PreferencesService2
  }
}

final class ListTypeSelectionViewModel: NSObject, Stepper, BaseViewModel {
  
  // MARK: - Routing
  
  let steps = PublishRelay<Step>()
  
  // MARK: - Properties
  
  let dependencies: Dependencies
  
  // MARK: - Events
  
  let onDidSelectNearbySubject = PublishSubject<Void>()
  let onDidSelectBookmarksSubject = PublishSubject<Void>()
  
  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }
  
  // MARK: - Functions
  
  public func observeEvents() {
    observeUserTapEvents()
  }
}

// MARK: - Observations

private extension ListTypeSelectionViewModel {
  
  func observeUserTapEvents() {
    _ = onDidSelectNearbySubject
      .asSingle()
      .flatMapCompletable { [dependencies] _ -> Completable in
        dependencies.preferencesService.setPreferredListTypeOption(ListTypeOption(value: .nearby))
      }
      .subscribe { [weak steps] _ in steps?.accept(ListStep.dismissChildFlow) }
    
    _ = onDidSelectBookmarksSubject
      .asSingle()
      .flatMapCompletable { [dependencies] _ -> Completable in
        dependencies.preferencesService.setPreferredListTypeOption(ListTypeOption(value: .bookmarked))
      }
      .subscribe { [weak steps] _ in steps?.accept(ListStep.dismissChildFlow) }
  }
}
