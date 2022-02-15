//
//  SortingOrientationSelectionAlertController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import UIKit.UIAlertController
import RxSwift
import RxFlow

// MARK: - Delegate

protocol SortingOrientationSelectionAlertDelegate: class {
  func didSortingOrientationOption(_ selectedOption: SortingOrientationOption)
}

// MARK: - Dependencies

extension SortingOrientationSelectionAlert {
  struct Dependencies {
    weak var selectionDelegate: SortingOrientationSelectionAlertDelegate?
    let selectedOptionValue: SortingOrientationValue
  }
}

// MARK: - Class Definition

final class SortingOrientationSelectionAlert {
  
  // MARK: - Actions
  
  fileprivate lazy var nameSortingSelectionAction = Factory.AlertAction.make(fromType: .standard(title: ListTypeValue.nearby.title, handler: { [dependencies] _ in
    dependencies.selectionDelegate?.didSortingOrientationOption(SortingOrientationOption(value: .name))
  }))
  fileprivate lazy var temperatureSortingSelectionAction = Factory.AlertAction.make(fromType: .standard(title: ListTypeValue.bookmarked.title, handler: { [dependencies] _ in
    dependencies.selectionDelegate?.didSortingOrientationOption(SortingOrientationOption(value: .temperature))
  }))
  fileprivate lazy var distanceSortingSelectionAction = Factory.AlertAction.make(fromType: .standard(title: ListTypeValue.bookmarked.title, handler: { [dependencies] _ in
    dependencies.selectionDelegate?.didSortingOrientationOption(SortingOrientationOption(value: .distance))
  }))
  fileprivate lazy var cancelAction = Factory.AlertAction.make(fromType: .cancel)
  
  // MARK: - Properties
  
  let dependencies: Dependencies
  let alertController: UIAlertController
  
  // MARK: - Initialization
  
  required init(dependencies: Dependencies) {
    self.dependencies = dependencies
    
    alertController = UIAlertController(
      title: R.string.localizable.select_list_type().capitalized,
      message: nil,
      preferredStyle: .alert
    )
    
    alertController.addAction(nameSortingSelectionAction)
    alertController.addAction(temperatureSortingSelectionAction)
    alertController.addAction(distanceSortingSelectionAction)
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

// MARK: - Private Helpers

private extension SortingOrientationSelectionAlert {
  
  func setCheckmarkForOption(with value: SortingOrientationValue) {
    var action: UIAlertAction
    
    switch dependencies.selectedOptionValue {
    case .name:
      action = nameSortingSelectionAction
    case .temperature:
      action = temperatureSortingSelectionAction
    case .distance:
      action = distanceSortingSelectionAction
    }
    
    action.setValue(true, forKey: Constants.Keys.KeyValueBindings.kChecked)
  }
}
