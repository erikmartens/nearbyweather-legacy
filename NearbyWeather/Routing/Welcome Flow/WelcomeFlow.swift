//
//  WelcomeFlow.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxFlow
import Swinject

// MARK: - Dependencies

extension WelcomeFlow {
  struct Dependencies {
    let dependencyContainer: Container
  }
}

// MARK: - Class Definition

final class WelcomeFlow: Flow {
  
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
    guard let step = step as? WelcomeStep else {
      return .none
    }
    switch step {
    case .setApiKey:
      return summonWelcomeWindow()
    case .apiInstructions:
      return summonInstructions()
    case .setPermissions:
      return summonSetPermissions()
    case .dismiss:
      return dismissWelcomeWindow()
    }
  }
}

private extension WelcomeFlow {
  
  private func summonWelcomeWindow() -> FlowContributors {
   
    let setApiKeyViewController = SetApiKeyViewController(
      dependencies: SetApiKeyViewController.ViewModel.Dependencies(apiKeyService: dependencies.dependencyContainer.resolve(ApiKeyService.self)!
    ))
    rootViewController.setViewControllers([setApiKeyViewController], animated: false)
    return .one(flowContributor: .contribute(
      withNextPresentable: setApiKeyViewController,
      withNextStepper: setApiKeyViewController.viewModel,
      allowStepWhenNotPresented: true
    ))
  }
  
  private func summonInstructions() -> FlowContributors {
    rootViewController.presentSafariViewController(for: Constants.Urls.kOpenWeatherMapInstructionsUrl)
    return .none
  }
  
  private func summonSetPermissions() -> FlowContributors {
    
    let setPermissionsViewController = SetPermissionsViewController(
      dependencies: SetPermissionsViewController.ViewModel.Dependencies(
        userLocationService: dependencies.dependencyContainer.resolve(UserLocationService.self)!,
        weatherInformationService: dependencies.dependencyContainer.resolve(WeatherInformationService.self)!,
        applicationCycleService: dependencies.dependencyContainer.resolve(ApplicationCycleService.self)!
    ))
    rootViewController.pushViewController(setPermissionsViewController, animated: true)
    return .one(flowContributor: .contribute(
      withNextPresentable: setPermissionsViewController,
      withNextStepper: setPermissionsViewController.viewModel
    ))
  }
  
  private func dismissWelcomeWindow() -> FlowContributors {
    .end(forwardToParentFlowWithStep: WelcomeStep.dismiss)
  }
}
