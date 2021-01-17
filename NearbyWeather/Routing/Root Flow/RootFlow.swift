//
//  RootFlow.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxFlow
import Swinject

// MARK: - Dependencies

extension RootFlow {
  struct Dependencies {
    let rootWindow: UIWindow
    let dependencyContainer: Container
  }
}

// MARK: - Class Definition

final class RootFlow: Flow {
  
  // MARK: - Assets
  
  var root: Presentable {
    dependencies.rootWindow
  }
  
  // MARK: - Properties
  
  let dependencies: Dependencies
  
  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }
  
  // MARK: - Functions
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = transform(step: step) as? RootStep else {
      return .none
    }
    switch step {
    case .main:
      return summonMainWindow()
    case .welcome:
      return summonWelcomeWindow()
    case .dimissWelcome:
      return dismissWelcomeWindow()
    }
  }
  
  private func transform(step: Step) -> Step? {
    if let welcomeStep = step as? WelcomeStep {
      switch welcomeStep {
      case .dismiss:
        return RootStep.main
      default:
        return nil
      }
    }
    return step
  }
}

// MARK: - Summoning Functions

private extension RootFlow {
  
  func summonMainWindow() -> FlowContributors {
    let mainFlow = MainFlow(dependencies: MainFlow.Dependencies(dependencyContainer: dependencies.dependencyContainer))
    
    Flows.whenReady(flow1: mainFlow) { [dependencies] (mainRoot: UITabBarController) in
      dependencies.rootWindow.rootViewController = mainRoot
      dependencies.rootWindow.makeKeyAndVisible()
    }
    
    return .one(flowContributor: .contribute(withNextPresentable: mainFlow, withNextStepper: MainStepper()))
  }
  
  func summonWelcomeWindow() -> FlowContributors {
    let welcomeFlow = WelcomeFlow()
    
    Flows.whenReady(flow1: welcomeFlow) { [dependencies] (welcomeRoot: UINavigationController) in
      dependencies.rootWindow.rootViewController = welcomeRoot
      dependencies.rootWindow.makeKeyAndVisible()
    }
    
    return .one(flowContributor: .contribute(withNextPresentable: welcomeFlow, withNextStepper: WelcomeStepper()))
  }
  
  func dismissWelcomeWindow() -> FlowContributors {
    let mainFlow = MainFlow(dependencies: MainFlow.Dependencies(dependencyContainer: dependencies.dependencyContainer))
    
    Flows.whenReady(flow1: mainFlow) { [dependencies] (mainRoot: UITabBarController) in
      UIView.animate(withDuration: 0.2, animations: {
        dependencies.rootWindow.alpha = 0
        dependencies.rootWindow.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
      }, completion: { _ in
        dependencies.rootWindow.rootViewController = mainRoot
        dependencies.rootWindow.alpha = 1
      })
    }
    
    return .one(flowContributor: .contribute(withNextPresentable: mainFlow, withNextStepper: MainStepper()))
  }
}
