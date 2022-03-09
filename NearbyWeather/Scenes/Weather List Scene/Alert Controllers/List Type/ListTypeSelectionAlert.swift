//
//  ListTypeSelectionAlertController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import UIKit.UIAlertController
import RxSwift
import RxFlow

// MARK: - Delegate

protocol ListTypeSelectionAlertDelegate: class {
  func didSelectListTypeOption(_ selectedOption: ListTypeOption)
}

// MARK: - Dependencies

extension ListTypeSelectionAlert {
  struct Dependencies {
    weak var selectionDelegate: ListTypeSelectionAlertDelegate?
    let selectedOptionValue: ListTypeOptionValue
  }
}

// MARK: - Class Definition

final class ListTypeSelectionAlert {
  
  // MARK: - Actions
  
  fileprivate lazy var nearbySelectionAction = Factory.AlertAction.make(fromType: .standard(title: ListTypeOptionValue.nearby.title, handler: { [dependencies] _ in
    dependencies.selectionDelegate?.didSelectListTypeOption(ListTypeOption(value: .nearby))
  }))
  fileprivate lazy var bookmarksSelectionAction = Factory.AlertAction.make(fromType: .standard(title: ListTypeOptionValue.bookmarked.title, handler: { [dependencies] _ in
    dependencies.selectionDelegate?.didSelectListTypeOption(ListTypeOption(value: .bookmarked))
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
    
    alertController.addAction(bookmarksSelectionAction)
    alertController.addAction(nearbySelectionAction)
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
  
private extension ListTypeSelectionAlert {
  
  private func setCheckmarkForOption(with value: ListTypeOptionValue) {
    var action: UIAlertAction
    
    switch dependencies.selectedOptionValue {
    case .bookmarked:
      action = bookmarksSelectionAction
    case .nearby:
      action = nearbySelectionAction
    }
    
    action.setValue(true, forKey: Constants.Keys.KeyValueBindings.kChecked)
  }
}
