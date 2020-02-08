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

class Stepper {
  
  weak var coordinator: Coordinator?

  // MARK: - Initialization
  
  init<T: StepProtocol>(coordinator: Coordinator?, type: T.Type) {
    self.coordinator = coordinator
  }
  
  // MARK: - Functions
  
  func emitStep<T: StepProtocol>(_ step: T, type: T.Type) {
    NotificationCenter.default.post(
      name: Notification.Name(rawValue: T.identifier),
      object: self,
      userInfo: [Constants.Keys.AppCoordinator.kStep: step]
    )
  }
}
