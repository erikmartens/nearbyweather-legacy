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

final class MapTypeSelectionAlertController: UIAlertController, BaseViewController {
  
  typealias ViewModel = MapTypeSelectionAlertViewModel
  
  // MARK: - Actions
  
  fileprivate lazy var standardSelectionAction = Factory.AlertAction.make(fromType: .standard(title: MapTypeValue.standard.title, handler: { [weak viewModel] _ in
    viewModel?.onDidSelectOptionSubject.onNext(MapTypeOption(value: .standard))
  }))
  fileprivate lazy var satelliteSelectionAction = Factory.AlertAction.make(fromType: .standard(title: MapTypeValue.satellite.title, handler: { [weak viewModel] _ in
    viewModel?.onDidSelectOptionSubject.onNext(MapTypeOption(value: .satellite))
  }))
  fileprivate lazy var hybridSelectionAction = Factory.AlertAction.make(fromType: .standard(title: MapTypeValue.hybrid.title, handler: { [weak viewModel] _ in
    viewModel?.onDidSelectOptionSubject.onNext(MapTypeOption(value: .hybrid))
  }))
  fileprivate lazy var cancelAction = Factory.AlertAction.make(fromType: .cancel)
  
  // MARK: - Properties
  
  let viewModel: ViewModel
  
  override var preferredStyle: UIAlertController.Style { .alert }
  override var actions: [UIAlertAction] {
    [standardSelectionAction,
     satelliteSelectionAction,
     hybridSelectionAction,
     cancelAction]
  }
  
  // MARK: - Initialization
  
  required init(dependencies: ViewModel.Dependencies) {
    viewModel = MapTypeSelectionAlertViewModel(dependencies: dependencies)
    
    super.init(nibName: nil, bundle: nil)
    title = R.string.localizable.select_list_type().capitalized
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

extension MapTypeSelectionAlertController {
  
  func setupBindings() {
    viewModel.observeEvents()
    bindContentFromViewModel(viewModel)
    bindUserInputToViewModel(viewModel)
  }
}
  
// MARK: - Helpers
  
private extension MapTypeSelectionAlertController {
  
  private func setCheckmarkForOption(with value: MapTypeValue) {
    var action: UIAlertAction
    
    switch viewModel.dependencies.selectedOptionValue {
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
