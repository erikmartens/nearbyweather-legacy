//
//  Coordinator.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 01.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit

// MARK: - Coordinator

enum NextCoordinator {
  case none
  case single(Coordinator)
  case multiple([Coordinator])
  case destroy(Coordinator)
}

protocol CoordinatorProtocol {
  var identifier: String { get }
  var parentCoordinator: Coordinator? { get }
  var childCoordinators: [Coordinator] { get }
  var rootViewController: UIViewController { get }
  var stepper: Stepper { get }
  func didReceiveStep(_ notification: Notification)
  func executeRoutingStep(_ step: StepProtocol, passNextChildCoordinatorTo coordinatorReceiver: @escaping (NextCoordinator) -> Void)
}

class Coordinator: CoordinatorProtocol {
  
  // MARK: - Properties
  
  let rootViewController: UIViewController
  let stepper: Stepper
  weak var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator]
  
  lazy var identifier: String = {
    return UUID().uuidString
  }()
  
  // MARK: - Initialization
  
  init<T: StepProtocol>(rootViewController: UIViewController, stepper: Stepper, parentCoordinator: Coordinator?, type: T.Type) {
    self.rootViewController = rootViewController
    self.stepper = stepper
    self.parentCoordinator = parentCoordinator
    self.childCoordinators = []
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(Self.didReceiveStep),
      name: Notification.Name(rawValue: T.identifier),
      object: nil
    )
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Functions
  
  @objc func didReceiveStep(_ notification: Notification) {
    didReceiveStep(notification, type: Step.self)
  }
  
  func didReceiveStep<T: StepProtocol>(_ notification: Notification, type: T.Type) {
    guard let userInfo = notification.userInfo as? [String: T],
      let step = userInfo[Constants.Keys.AppCoordinator.kStep] else {
        return
    }
    executeRoutingStep(step) { [weak self] nextChildCoordinator in
      guard let self = self else { return }
      switch nextChildCoordinator {
      case .none:
        break
      case let .single(coordinator):
        self.childCoordinators.append(coordinator)
        coordinator.stepper.emitInitialStep()
      case let .multiple(coordinators):
        self.childCoordinators.append(contentsOf: coordinators)
        coordinators.forEach { $0.stepper.emitInitialStep() }
      case let .destroy(coordinator):
        self.childCoordinators.removeAll(where: { $0 == coordinator })
      }
    }
  }
  
  /// The next step is expected to pass the following coordinator after having completed the internal setup process
  /// if such a coordinator is required for subseqent coordination.
  func executeRoutingStep(_ step: StepProtocol, passNextChildCoordinatorTo coordinatorReceiver: @escaping (NextCoordinator) -> Void) {}
}

extension Coordinator: Equatable {
  
  static func == (lhs: Coordinator, rhs: Coordinator) -> Bool {
    return lhs.identifier == rhs.identifier
  }
}
