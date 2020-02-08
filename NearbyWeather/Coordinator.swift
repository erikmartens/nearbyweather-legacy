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
  var initialStep: StepProtocol { get }
  var associatedStepperIdentifier: String { get }
  func didReceiveStep(_ notification: Notification)
  func executeRoutingStep(_ step: StepProtocol, passNextChildCoordinatorTo coordinatorReceiver: @escaping (NextCoordinator) -> Void)
}

class Coordinator: CoordinatorProtocol {
  
  // MARK: - Properties
  
  let rootViewController: UIViewController
  weak var parentCoordinator: Coordinator?
  var childCoordinators: [Coordinator]
  
  var identifier: String {
    return String(describing: self)
  }
  
  var initialStep: StepProtocol {
    return Step.none
  }
  
  var associatedStepperIdentifier: String {
    return Step.identifier
  }
  
  // MARK: - Initialization
  
  init<T: StepProtocol>(rootViewController: UIViewController, parentCoordinator: Coordinator?, type: T.Type) {
    self.rootViewController = rootViewController
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
        self.postInitialStep(for: coordinator)
      case let .multiple(coordinators):
        self.childCoordinators.append(contentsOf: coordinators)
        coordinators.forEach(self.postInitialStep)
      case let .destroy(coordinator):
        self.childCoordinators.removeAll(where: { $0 == coordinator })
      }
    }
  }
  
  /// The next step is expected to pass the following coordinator after having completed the internal setup process
  /// if such a coordinator is required for subseqent coordination.
  func executeRoutingStep(_ step: StepProtocol, passNextChildCoordinatorTo coordinatorReceiver: @escaping (NextCoordinator) -> Void) {}
}

// MARK: - Private Helper Functions

private extension Coordinator {
  
  // TODO: delegate to own stepper
  func postInitialStep(for coordinator: Coordinator) {
    NotificationCenter.default.post(
      name: Notification.Name(rawValue: coordinator.associatedStepperIdentifier),
      object: self,
      userInfo: [Constants.Keys.AppCoordinator.kStep: coordinator.initialStep]
    )
  }
}

extension Coordinator: Equatable {
  
  static func == (lhs: Coordinator, rhs: Coordinator) -> Bool {
    return lhs.identifier == rhs.identifier
  }
}
