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
    let selectedOptionValue: MapTypeValue
  }
}

// MARK: - Class Definition

final class MapTypeSelectionAlert {
  
  // MARK: - Actions
  
  fileprivate lazy var standardSelectionAction = Factory.AlertAction.make(fromType: .standard(title: MapTypeValue.standard.title, handler: { [dependencies] _ in
    dependencies.selectionDelegate?.didSelectMapTypeOption(MapTypeOption(value: .standard))
  }))
  fileprivate lazy var satelliteSelectionAction = Factory.AlertAction.make(fromType: .standard(title: MapTypeValue.satellite.title, handler: { [dependencies] _ in
    dependencies.selectionDelegate?.didSelectMapTypeOption(MapTypeOption(value: .satellite))
  }))
  fileprivate lazy var hybridSelectionAction = Factory.AlertAction.make(fromType: .standard(title: MapTypeValue.hybrid.title, handler: { [dependencies] _ in
    dependencies.selectionDelegate?.didSelectMapTypeOption(MapTypeOption(value: .hybrid))
  }))
  fileprivate lazy var cancelAction = Factory.AlertAction.make(fromType: .cancel)
  
  // MARK: - Properties
  
  let dependencies: Dependencies
  let alertController: UIAlertController
  
//  override var preferredStyle: UIAlertController.Style { .alert }
  
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
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
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
  
  private func setCheckmarkForOption(with value: MapTypeValue) {
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
