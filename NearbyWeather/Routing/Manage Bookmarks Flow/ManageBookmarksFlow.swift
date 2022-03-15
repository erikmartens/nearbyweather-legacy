//
//  ManageBookmarksFlow.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 15.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxFlow
import Swinject
import MessageUI

// MARK: - Dependencies

extension ManageBookmarksFlow {
  struct Dependencies {
    let flowPresentationStyle: FlowPresentationStyle
    let endingStep: Step
    let dependencyContainer: Container
  }
}

// MARK: - Class Definition

final class ManageBookmarksFlow: Flow {
  
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
    guard let step = step as? ManageBookmarksStep else {
      return .none
    }
    switch step {
    case .manageBookmarks:
      return summonManageBookmarksViewController()
    case .end:
      return endManageBookmarksFlow()
    }
  }
}

// MARK: - Summoning Functions

private extension ManageBookmarksFlow {
  
  func summonManageBookmarksViewController() -> FlowContributors {
    let manageBookmarksViewController = ManageBookmarksViewController(dependencies: ManageBookmarksViewController.ViewModel.Dependencies(
      weatherStationService: dependencies.dependencyContainer.resolve(WeatherStationService.self)!
    ))
    
    switch dependencies.flowPresentationStyle {
    case .pushed:
      rootViewController.pushViewController(manageBookmarksViewController, animated: true)
    case .presented:
      rootViewController.setViewControllers([manageBookmarksViewController], animated: false)
    }
    
    return .one(flowContributor: .contribute(withNextPresentable: manageBookmarksViewController, withNextStepper: manageBookmarksViewController.viewModel))
  }
  
  func endManageBookmarksFlow() -> FlowContributors {
    .end(forwardToParentFlowWithStep: dependencies.endingStep)
  }
}
