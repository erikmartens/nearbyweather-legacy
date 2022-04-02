//
//  MainFlow.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxFlow
import Swinject

// MARK: - Dependencies

extension MainFlow {
  struct Dependencies {
    let dependencyContainer: Container
  }
}

// MARK: - Class Definition

final class MainFlow: Flow {

  // MARK: - Assets

  var root: Presentable {
    rootViewController
  }

  private lazy var rootViewController = Factory.TabBarController.make(fromType: .standard)
  
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
    guard let step = step as? MainStep else {
      return .none
    }
    switch step {
    case .main:
      return summonRootTabBar()
    }
  }
}

// MARK: - Summoning Functions

private extension MainFlow {

  func summonRootTabBar() -> FlowContributors {

    let listFlow = WeatherListFlow(dependencies: WeatherListFlow.Dependencies(dependencyContainer: dependencies.dependencyContainer))
    let mapFlow = WeatherMapFlow(dependencies: WeatherMapFlow.Dependencies(dependencyContainer: dependencies.dependencyContainer))
    let settingsFlow = SettingsFlow(dependencies: SettingsFlow.Dependencies(dependencyContainer: dependencies.dependencyContainer))

    Flows.use([listFlow, mapFlow, settingsFlow], when: .ready) { [unowned rootViewController] rootViewControllers in
      rootViewController.viewControllers = rootViewControllers
    }

    return .multiple(flowContributors: [
      .contribute(withNextPresentable: listFlow, withNextStepper: WeatherListStepper(dependencyContainer: dependencies.dependencyContainer)),
      .contribute(withNextPresentable: mapFlow, withNextStepper: WeatherMapStepper()),
      .contribute(withNextPresentable: settingsFlow, withNextStepper: SettingsStepper())
    ])
  }
}
