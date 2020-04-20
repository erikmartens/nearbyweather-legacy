//
//  WelcomeFlow.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxFlow

final class WelcomeFlow: Flow {
  
  // MARK: - Assets
  
  var root: Presentable {
    rootViewController
  }
  
  private lazy var rootViewController: UINavigationController = {
    Factory.NavigationController.make(fromType: .standard)
  }()
  
  // MARK: - Initialization
  
  init() {}
  
  deinit {
    printDebugMessage(domain: String(describing: self), message: "was deinitialized")
  }
  
  // MARK: - Functions
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? WelcomeStep else {
      return .none
    }
    switch step {
    case .setApiKey:
      return summonWelcomeWindow()
    case .setPermissions:
      return summonSetPermissions()
    case .dismiss:
      return dismissWelcomeWindow()
    }
  }
}

private extension WelcomeFlow {
  
  private func summonWelcomeWindow() -> FlowContributors {
   
    let welcomeViewController = R.storyboard.setApiKey.setApiKeyViewController()!
    rootViewController.setViewControllers([welcomeViewController], animated: false)
    return .one(flowContributor: .contribute(withNext: welcomeViewController))
  }
  
  private func summonSetPermissions() -> FlowContributors {
    let setPermissionsController = R.storyboard.setPermissions.setPermissionsVC()!
    rootViewController.pushViewController(setPermissionsController, animated: true)
    return .one(flowContributor: .contribute(withNext: setPermissionsController))
  }
  
  private func dismissWelcomeWindow() -> FlowContributors {
    .end(forwardToParentFlowWithStep: WelcomeStep.dismiss)
  }
}
