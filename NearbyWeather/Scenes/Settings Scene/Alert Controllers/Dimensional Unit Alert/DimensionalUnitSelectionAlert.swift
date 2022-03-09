//
//  DimensionalUnitSelectionAlert.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 09.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import UIKit.UIAlertController
import RxSwift
import RxFlow

// MARK: - Delegate

protocol DimensionalUnitSelectionAlertDelegate: class {
  func didSelectDimensionalUnitOption(_ selectedOption: DimensionalUnitOption)
}

// MARK: - Dependencies

extension DimensionalUnitSelectionAlert {
  struct Dependencies {
    weak var selectionDelegate: DimensionalUnitSelectionAlertDelegate?
    let selectedOptionValue: DimensionalUnitOptionValue
  }
}

// MARK: - Class Definition

final class DimensionalUnitSelectionAlert {
  
  // MARK: - Actions
  
  fileprivate lazy var metricSelectionAction = Factory.AlertAction.make(fromType: .standard(title: DimensionalUnitOptionValue.metric.title, handler: { [dependencies] _ in
    dependencies.selectionDelegate?.didSelectDimensionalUnitOption(DimensionalUnitOption(value: .metric))
  }))
  fileprivate lazy var imperialSelectionAction = Factory.AlertAction.make(fromType: .standard(title: DimensionalUnitOptionValue.imperial.title, handler: { [dependencies] _ in
    dependencies.selectionDelegate?.didSelectDimensionalUnitOption(DimensionalUnitOption(value: .imperial))
  }))
  fileprivate lazy var cancelAction = Factory.AlertAction.make(fromType: .cancel)
  
  // MARK: - Properties
  
  let dependencies: Dependencies
  let alertController: UIAlertController
  
  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
    alertController = UIAlertController(
      title: R.string.localizable.distanceSpeed_unit().capitalized,
      message: nil,
      preferredStyle: .alert
    )
    
    alertController.addAction(metricSelectionAction)
    alertController.addAction(imperialSelectionAction)
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
  
private extension DimensionalUnitSelectionAlert {
  
  private func setCheckmarkForOption(with value: DimensionalUnitOptionValue) {
    var action: UIAlertAction
    
    switch dependencies.selectedOptionValue {
    case .metric:
      action = metricSelectionAction
    case .imperial:
      action = imperialSelectionAction
    }
    
    action.setValue(true, forKey: Constants.Keys.KeyValueBindings.kChecked)
  }
}
