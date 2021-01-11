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

final class ListTypeSelectionAlertController: UIAlertController, BaseViewController {  
  
  typealias ViewModel = ListTypeSelectionAlertViewModel
  
  // MARK: - Actions
  
  fileprivate lazy var nearbySelectionAction = Factory.AlertAction.make(fromType: .standard(title: ListTypeValue.nearby.title, handler: { [weak viewModel] _ in
    viewModel?.onDidSelectOptionSubject.onNext(ListTypeOption(value: .nearby))
  }))
  fileprivate lazy var bookmarksSelectionAction = Factory.AlertAction.make(fromType: .standard(title: ListTypeValue.bookmarked.title, handler: { [weak viewModel] _ in
    viewModel?.onDidSelectOptionSubject.onNext(ListTypeOption(value: .bookmarked))
  }))
  fileprivate lazy var cancelAction = Factory.AlertAction.make(fromType: .cancel)
  
  // MARK: - Properties
  
  let viewModel: ViewModel
  
  override var preferredStyle: UIAlertController.Style { .alert }
  override var actions: [UIAlertAction] {
    [bookmarksSelectionAction,
     nearbySelectionAction,
     cancelAction]
  }
  
  // MARK: - Initialization
  
  required init(dependencies: ViewModel.Dependencies) {
    viewModel = ListTypeSelectionAlertViewModel(dependencies: dependencies)
    
    super.init(nibName: nil, bundle: nil)
    title = R.string.localizable.select_list_type().capitalized
    message = nil
    
    setCheckmarkForOption(with: viewModel.dependencies.selectedOptionValue)
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
  
  // MARK: - AlertController LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupBindings()
  }
}

// MARK: - ViewModel Bindings

extension ListTypeSelectionAlertController {
  
  func setupBindings() {
    viewModel.observeEvents()
    bindContentFromViewModel(viewModel)
    bindUserInputToViewModel(viewModel)
  }
}
  
// MARK: - Helpers
  
private extension ListTypeSelectionAlertController {
  
  private func setCheckmarkForOption(with value: ListTypeValue) {
    var action: UIAlertAction
    
    switch viewModel.dependencies.selectedOptionValue {
    case .bookmarked:
      action = bookmarksSelectionAction
    case .nearby:
      action = nearbySelectionAction
    }
    
    action.setValue(true, forKey: Constants.Keys.KeyValueBindings.kChecked)
  }
}
