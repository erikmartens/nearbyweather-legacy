//
//  ApiKeyInputFlow.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxFlow
import Swinject
import MessageUI

// MARK: - Dependencies

extension ApiKeyInputFlow {
  struct Dependencies {
    let flowPresentationStyle: FlowPresentationStyle
    let endingStep: Step
    let dependencyContainer: Container
  }
}

// MARK: - Class Definition

final class ApiKeyInputFlow: Flow {
  
  // MARK: - Assets
  
  var root: Presentable {
    rootViewController
  }
  
  lazy var rootViewController: UINavigationController = {
    switch dependencies.flowPresentationStyle {
    case let .pushed(rootViewController):
      return rootViewController
    case .presented:
      return Factory.NavigationController.make(fromType: .standard)
    }
  }()
  
  // MARK: - Dependencies
  
  private let dependencies: Dependencies
  
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
    guard let step = step as? ApiKeyInputStep else {
      return .none
    }
    switch step {
    case .apiKeyInput:
      return summonApiKeyInputViewController()
    case .end:
      return endApiKeyInputFlow()
    }
  }
}

// MARK: - Summoning Functions

private extension ApiKeyInputFlow {
  
  func summonApiKeyInputViewController() -> FlowContributors {
    let apiKeyInputViewController = ApiKeyInputViewController(dependencies: ApiKeyInputViewController.ViewModel.Dependencies(
      apiKeyService: dependencies.dependencyContainer.resolve(ApiKeyService.self)!
    ))
    
    switch dependencies.flowPresentationStyle {
    case .pushed:
      rootViewController.pushViewController(apiKeyInputViewController, animated: true)
    case .presented:
      rootViewController.setViewControllers([apiKeyInputViewController], animated: false)
    }
    
    return .one(flowContributor: .contribute(withNextPresentable: apiKeyInputViewController, withNextStepper: apiKeyInputViewController.viewModel))
  }
  
  func endApiKeyInputFlow() -> FlowContributors {
    .end(forwardToParentFlowWithStep: dependencies.endingStep)
  }
}
