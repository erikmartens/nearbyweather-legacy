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

final class AmountOfNearbyResultsSelectionAlertController: UIAlertController, BaseViewController {
  
  typealias ViewModel = AmountOfNearbyResultsSelectionAlertViewModel
  
  // MARK: - Actions
  
  fileprivate lazy var tenNearbyResultsSelectionAction = Factory.AlertAction.make(fromType: .standard(title: ListTypeValue.nearby.title, handler: { [weak viewModel] _ in
    viewModel?.onDidSelectOptionSubject.onNext(AmountOfResultsOption(value: .ten))
  }))
  fileprivate lazy var twentyNearbyResultsSelectionAction = Factory.AlertAction.make(fromType: .standard(title: ListTypeValue.nearby.title, handler: { [weak viewModel] _ in
    viewModel?.onDidSelectOptionSubject.onNext(AmountOfResultsOption(value: .twenty))
  }))
  fileprivate lazy var thirtyNearbyResultsSelectionAction = Factory.AlertAction.make(fromType: .standard(title: ListTypeValue.nearby.title, handler: { [weak viewModel] _ in
    viewModel?.onDidSelectOptionSubject.onNext(AmountOfResultsOption(value: .thirty))
  }))
  fileprivate lazy var fortyNearbyResultsSelectionAction = Factory.AlertAction.make(fromType: .standard(title: ListTypeValue.nearby.title, handler: { [weak viewModel] _ in
    viewModel?.onDidSelectOptionSubject.onNext(AmountOfResultsOption(value: .forty))
  }))
  fileprivate lazy var fiftyNearbyResultsSelectionAction = Factory.AlertAction.make(fromType: .standard(title: ListTypeValue.nearby.title, handler: { [weak viewModel] _ in
    viewModel?.onDidSelectOptionSubject.onNext(AmountOfResultsOption(value: .fifty))
  }))
  fileprivate lazy var cancelAction = Factory.AlertAction.make(fromType: .cancel)
  
  // MARK: - Properties
  
  let viewModel: ViewModel
  
  override var preferredStyle: UIAlertController.Style { .alert }
  override var actions: [UIAlertAction] {
    [tenNearbyResultsSelectionAction,
     twentyNearbyResultsSelectionAction,
     thirtyNearbyResultsSelectionAction,
     fortyNearbyResultsSelectionAction,
     fiftyNearbyResultsSelectionAction,
     cancelAction]
  }
  
  // MARK: - Initialization
  
  required init(dependencies: ViewModel.Dependencies) {
    viewModel = AmountOfNearbyResultsSelectionAlertViewModel(dependencies: dependencies)
    
    super.init(nibName: nil, bundle: nil)
    title = R.string.localizable.amount_of_results().capitalized
    message = nil
    
    setCheckmarkForOption(with: viewModel.dependencies.selectedOptionValue)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - AlertController LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupBindings()
  }
}

// MARK: - ViewModel Bindings

extension AmountOfNearbyResultsSelectionAlertController {
  
  func setupBindings() {
    viewModel.observeEvents()
    bindContentFromViewModel(viewModel)
    bindUserInputToViewModel(viewModel)
  }
}
  
// MARK: - Helpers
  
private extension AmountOfNearbyResultsSelectionAlertController {
  
  func setCheckmarkForOption(with value: AmountOfResultsValue) {
    var action: UIAlertAction
    
    switch viewModel.dependencies.selectedOptionValue {
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
