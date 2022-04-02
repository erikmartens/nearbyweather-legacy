//
//  LoadingFlow.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxFlow

// MARK: - Dependencies

extension LoadingFlow {
  struct Dependencies {}
}

// MARK: - Class Definition

final class LoadingFlow: Flow {
  
  // MARK: - Assets
  
  var root: Presentable {
    rootViewController
  }
  
  private lazy var rootViewController = Factory.NavigationController.make(fromType: .standard)
  
  // MARK: - Properties
  
  let dependencies: Dependencies
  
  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
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
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? LoadingStep else {
      return .none
    }
    switch step {
    case .loading:
      return summonLoadingController()
    }
  }
}

private extension LoadingFlow {
  
  func summonLoadingController() -> FlowContributors {
    let loadingViewController = LoadingViewController(dependencies: LoadingViewController.ViewModel.Dependencies(title: R.string.localizable.tab_weatherList()))
    rootViewController.setViewControllers([loadingViewController], animated: false)
    return .one(flowContributor: .contribute(withNextPresentable: loadingViewController, withNextStepper: loadingViewController.viewModel))
  }
}
