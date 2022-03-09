//
//  MapTypeSelectionAlertController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import UIKit.UIAlertController
import RxSwift
import RxFlow

// MARK: - Delegate

protocol MapTypeSelectionAlertDelegate: class {
  func didSelectMapTypeOption(_ selectedOption: MapTypeOption)
}

// MARK: - Dependencies

extension MapTypeSelectionAlert {
  struct Dependencies {
    weak var selectionDelegate: MapTypeSelectionAlertDelegate?
    let selectedOptionValue: MapTypeOptionValue
  }
}

// MARK: - Class Definition

final class MapTypeSelectionAlert {
  
  // MARK: - Actions
  
  fileprivate lazy var standardSelectionAction = Factory.AlertAction.make(fromType: .standard(title: MapTypeOptionValue.standard.title, handler: { [dependencies] _ in
    dependencies.selectionDelegate?.didSelectMapTypeOption(MapTypeOption(value: .standard))
  }))
  fileprivate lazy var satelliteSelectionAction = Factory.AlertAction.make(fromType: .standard(title: MapTypeOptionValue.satellite.title, handler: { [dependencies] _ in
    dependencies.selectionDelegate?.didSelectMapTypeOption(MapTypeOption(value: .satellite))
  }))
  fileprivate lazy var hybridSelectionAction = Factory.AlertAction.make(fromType: .standard(title: MapTypeOptionValue.hybrid.title, handler: { [dependencies] _ in
    dependencies.selectionDelegate?.didSelectMapTypeOption(MapTypeOption(value: .hybrid))
  }))
  fileprivate lazy var cancelAction = Factory.AlertAction.make(fromType: .cancel)
  
  // MARK: - Properties
  
  let dependencies: Dependencies
  let alertController: UIAlertController
  
  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
    alertController = UIAlertController(
      title: R.string.localizable.select_map_type().capitalized,
      message: nil,
      preferredStyle: .alert
    )
    
    alertController.addAction(standardSelectionAction)
    alertController.addAction(satelliteSelectionAction)
    alertController.addAction(hybridSelectionAction)
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
  
private extension MapTypeSelectionAlert {
  
  private func setCheckmarkForOption(with value: MapTypeOptionValue) {
    var action: UIAlertAction
    
    switch dependencies.selectedOptionValue {
    case .standard:
      action = standardSelectionAction
    case .satellite:
      action = satelliteSelectionAction
    case .hybrid:
      action = hybridSelectionAction
    }
    
    action.setValue(true, forKey: Constants.Keys.KeyValueBindings.kChecked)
  }
}
