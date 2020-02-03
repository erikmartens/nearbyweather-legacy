//
//  File.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 01.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit

protocol Step {}

protocol CoordinatorProtocol {
  var parentCoordinator: Coordinator? { get }
  var childCoordinators: [Coordinator] { get }
  var rootViewController: UIViewController { get }
  func executeRoutingStep(_ step: Step) -> Coordinator?
}

class Coordinator: CoordinatorProtocol {

  var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator]
  
  var rootViewController: UIViewController {
    return UINavigationController()
  }
  
  init(parentCoordinator: Coordinator?) {
    self.parentCoordinator = parentCoordinator
    self.childCoordinators = []
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  func executeRoutingStep(_ step: Step) -> Coordinator? { return nil }
}
