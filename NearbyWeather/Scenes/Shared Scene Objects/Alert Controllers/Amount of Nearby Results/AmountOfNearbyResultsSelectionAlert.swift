//
//  AmountOfNearbyResultsSelectionAlertController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import UIKit.UIAlertController
import RxSwift
import RxFlow

// MARK: - Delegate

protocol AmountOfResultsSelectionAlertDelegate: class {
  func didSelectAmountOfResultsOption(_ selectedOption: AmountOfResultsOption)
}

// MARK: - Dependencies

extension AmountOfNearbyResultsSelectionAlert {
  struct Dependencies {
    weak var selectionDelegate: AmountOfResultsSelectionAlertDelegate?
    let selectedOptionValue: AmountOfResultsOptionValue
  }
}

// MARK: - Class Definition

final class AmountOfNearbyResultsSelectionAlert {
  
  // MARK: - Actions
  
  fileprivate lazy var tenNearbyResultsSelectionAction = Factory.AlertAction.make(fromType: .standard(title: "\(AmountOfResultsOptionValue.ten.rawValue)", handler: { [dependencies] _ in
    dependencies.selectionDelegate?.didSelectAmountOfResultsOption(AmountOfResultsOption(value: .ten))
  }))
  fileprivate lazy var twentyNearbyResultsSelectionAction = Factory.AlertAction.make(fromType: .standard(title: "\(AmountOfResultsOptionValue.twenty.rawValue)", handler: { [dependencies] _ in
    dependencies.selectionDelegate?.didSelectAmountOfResultsOption(AmountOfResultsOption(value: .twenty))
  }))
  fileprivate lazy var thirtyNearbyResultsSelectionAction = Factory.AlertAction.make(fromType: .standard(title: "\(AmountOfResultsOptionValue.thirty.rawValue)", handler: { [dependencies] _ in
    dependencies.selectionDelegate?.didSelectAmountOfResultsOption(AmountOfResultsOption(value: .thirty))
  }))
  fileprivate lazy var fortyNearbyResultsSelectionAction = Factory.AlertAction.make(fromType: .standard(title: "\(AmountOfResultsOptionValue.forty.rawValue)", handler: { [dependencies] _ in
    dependencies.selectionDelegate?.didSelectAmountOfResultsOption(AmountOfResultsOption(value: .forty))
  }))
  fileprivate lazy var fiftyNearbyResultsSelectionAction = Factory.AlertAction.make(fromType: .standard(title: "\(AmountOfResultsOptionValue.fifty.rawValue)", handler: { [dependencies] _ in
    dependencies.selectionDelegate?.didSelectAmountOfResultsOption(AmountOfResultsOption(value: .fifty))
  }))
  fileprivate lazy var cancelAction = Factory.AlertAction.make(fromType: .cancel)
  
  // MARK: - Properties
  
  let dependencies: Dependencies
  let alertController: UIAlertController
  
  // MARK: - Initialization
  
  required init(dependencies: Dependencies) {
    self.dependencies = dependencies
    
    alertController = UIAlertController(
      title: R.string.localizable.amount_of_results().capitalized,
      message: nil,
      preferredStyle: .alert
    )
    
    alertController.addAction(tenNearbyResultsSelectionAction)
    alertController.addAction(twentyNearbyResultsSelectionAction)
    alertController.addAction(thirtyNearbyResultsSelectionAction)
    alertController.addAction(fortyNearbyResultsSelectionAction)
    alertController.addAction(fiftyNearbyResultsSelectionAction)
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

private extension AmountOfNearbyResultsSelectionAlert {
  
  func setCheckmarkForOption(with value: AmountOfResultsOptionValue) {
    var action: UIAlertAction
    
    switch dependencies.selectedOptionValue {
    case .ten:
      action = tenNearbyResultsSelectionAction
    case .twenty:
      action = twentyNearbyResultsSelectionAction
    case .thirty:
      action = thirtyNearbyResultsSelectionAction
    case .forty:
      action = fortyNearbyResultsSelectionAction
    case .fifty:
      action = fiftyNearbyResultsSelectionAction
    }
    
    action.setValue(true, forKey: Constants.Keys.KeyValueBindings.kChecked)
  }
}
