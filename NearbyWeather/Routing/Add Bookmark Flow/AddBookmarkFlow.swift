//
//  AddBookmarkFlow.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 12.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxFlow
import Swinject
import MessageUI

// MARK: - Dependencies

extension AddBookmarkFlow {
  struct Dependencies {
    let flowPresentationStyle: FlowPresentationStyle
    let endingStep: Step
    let dependencyContainer: Container
  }
}

// MARK: - Class Definition

final class AddBookmarkFlow: Flow {
  
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
    guard let step = step as? AddBookmarkStep else {
      return .none
    }
    switch step {
    case .addBookmark:
      return summonAddBookmarkViewController()
    case .end:
      return endApiKeyInputFlow()
    }
  }
}

// MARK: - Summoning Functions

private extension AddBookmarkFlow {
  
  func summonAddBookmarkViewController() -> FlowContributors {
    let addBookmarkViewController = AddBookmarkViewController(dependencies: AddBookmarkViewController.ViewModel.Dependencies(
      weatherStationService: dependencies.dependencyContainer.resolve(WeatherStationService2.self)!
    ))
    
    switch dependencies.flowPresentationStyle {
    case .pushed:
      rootViewController.pushViewController(addBookmarkViewController, animated: true)
    case .presented:
      rootViewController.setViewControllers([addBookmarkViewController], animated: false)
    }
    
    return .one(flowContributor: .contribute(withNextPresentable: addBookmarkViewController, withNextStepper: addBookmarkViewController.viewModel))
  }
  
  func endApiKeyInputFlow() -> FlowContributors {
    .end(forwardToParentFlowWithStep: dependencies.endingStep)
  }
}
