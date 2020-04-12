//
//  WeatherListStepper.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 08.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

final class WeatherListStepper: Stepper {
  
  override init<T>(initialStep: InitialStep, type: T.Type) where T: StepProtocol {
    super.init(initialStep: initialStep, type: type)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(Self.emitStepOnWeatherDataServiceDidUpdate),
      name: Notification.Name(rawValue: Constants.Keys.NotificationCenter.kWeatherServiceDidUpdate),
      object: nil
    )
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}

extension WeatherListStepper {
  
  func requestRouting(toStep step: WeatherListStep) {
    emitStep(step, type: WeatherListStep.self)
  }
}

private extension WeatherListStepper {
  @objc func emitStepOnWeatherDataServiceDidUpdate() {
    guard WeatherDataService.shared.hasDisplayableData else {
      requestRouting(toStep: .emptyList)
      return
    }
    requestRouting(toStep: .list)
  }
}
