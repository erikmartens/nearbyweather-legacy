//
//  TemperatureUnitSelectionAlert.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 09.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import UIKit.UIAlertController
import RxSwift
import RxFlow

// MARK: - Delegate

protocol TemperatureUnitSelectionAlertDelegate: AnyObject {
  func didSelectTemperatureUnitOption(_ selectedOption: TemperatureUnitOption)
}

// MARK: - Dependencies

extension TemperatureUnitSelectionAlert {
  struct Dependencies {
    weak var selectionDelegate: TemperatureUnitSelectionAlertDelegate?
    let selectedOptionValue: TemperatureUnitOptionValue
  }
}

// MARK: - Class Definition

final class TemperatureUnitSelectionAlert {
  
  // MARK: - Actions
  
  fileprivate lazy var celsiusSelectionAction = Factory.AlertAction.make(fromType: .standard(title: TemperatureUnitOptionValue.celsius.title, handler: { [dependencies] _ in
    dependencies.selectionDelegate?.didSelectTemperatureUnitOption(TemperatureUnitOption(value: .celsius))
  }))
  fileprivate lazy var fahrenheitSelectionAction = Factory.AlertAction.make(fromType: .standard(title: TemperatureUnitOptionValue.fahrenheit.title, handler: { [dependencies] _ in
    dependencies.selectionDelegate?.didSelectTemperatureUnitOption(TemperatureUnitOption(value: .fahrenheit))
  }))
  fileprivate lazy var kelvinSelectionAction = Factory.AlertAction.make(fromType: .standard(title: TemperatureUnitOptionValue.kelvin.title, handler: { [dependencies] _ in
    dependencies.selectionDelegate?.didSelectTemperatureUnitOption(TemperatureUnitOption(value: .kelvin))
  }))
  fileprivate lazy var cancelAction = Factory.AlertAction.make(fromType: .cancel)
  
  // MARK: - Properties
  
  let dependencies: Dependencies
  let alertController: UIAlertController
  
  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
    alertController = UIAlertController(
      title: R.string.localizable.temperature_unit().capitalized,
      message: nil,
      preferredStyle: .alert
    )
    
    alertController.addAction(celsiusSelectionAction)
    alertController.addAction(fahrenheitSelectionAction)
    alertController.addAction(kelvinSelectionAction)
    alertController.addAction(cancelAction)
    
    setCheckmarkForOption(with: dependencies.selectedOptionValue)
  }
  
  deinit {
    printDebugMessage(
      domain: String(describing: self),
      message: "was deinitialized",
      type: .info
    )
  }
}
  
// MARK: - Helpers
  
private extension TemperatureUnitSelectionAlert {
  
  private func setCheckmarkForOption(with value: TemperatureUnitOptionValue) {
    var action: UIAlertAction
    
    switch dependencies.selectedOptionValue {
    case .celsius:
      action = celsiusSelectionAction
    case .fahrenheit:
      action = fahrenheitSelectionAction
    case .kelvin:
      action = kelvinSelectionAction
    }
    
    action.setValue(true, forKey: Constants.Keys.KeyValueBindings.kChecked)
  }
}
