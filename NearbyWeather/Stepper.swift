//
//  Stepper.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 05.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

protocol StepperProtocol {
  var coordinator: Coordinator? { get }
}

struct InitialStep {
  let identifier: String
  let step: StepProtocol
}

class Stepper {
  
  // MARK: - Properties
  
  let initialStep: InitialStep

  // MARK: - Initialization
  
  init<T: StepProtocol>(initialStep: InitialStep, type: T.Type) {
    self.initialStep = initialStep
  }
  
  // MARK: - Functions
  
  func emitInitialStep() {
    NotificationCenter.default.post(
      name: Notification.Name(rawValue: initialStep.identifier),
      object: self,
      userInfo: [Constants.Keys.AppCoordinator.kStep: initialStep.step]
    )
  }
  
  func emitStep<T: StepProtocol>(_ step: T, type: T.Type) {
    NotificationCenter.default.post(
      name: Notification.Name(rawValue: T.identifier),
      object: self,
      userInfo: [Constants.Keys.AppCoordinator.kStep: step]
    )
  }
}
