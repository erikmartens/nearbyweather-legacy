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

final class SortingOrientationSelectionAlertController: UIAlertController, BaseViewController {
  
  typealias ViewModel = SortingOrientationSelectionViewModel
  
  // MARK: - Actions
  
  fileprivate lazy var nameSortingSelectionAction = Factory.AlertAction.make(fromType: .standard(title: ListTypeValue.nearby.title, handler: { [weak viewModel] _ in
    viewModel?.onDidSelectOptionSubject.onNext(SortingOrientationOption(value: .name))
  }))
  fileprivate lazy var temperatureSortingSelectionAction = Factory.AlertAction.make(fromType: .standard(title: ListTypeValue.bookmarked.title, handler: { [weak viewModel] _ in
    viewModel?.onDidSelectOptionSubject.onNext(SortingOrientationOption(value: .temperature))
  }))
  fileprivate lazy var distanceSortingSelectionAction = Factory.AlertAction.make(fromType: .standard(title: ListTypeValue.bookmarked.title, handler: { [weak viewModel] _ in
    viewModel?.onDidSelectOptionSubject.onNext(SortingOrientationOption(value: .distance))
  }))
  fileprivate lazy var cancelAction = Factory.AlertAction.make(fromType: .cancel)
  
  // MARK: - Properties
  
  let viewModel: ViewModel
  
  override var preferredStyle: UIAlertController.Style { .alert }
  override var actions: [UIAlertAction] {
    [nameSortingSelectionAction,
     temperatureSortingSelectionAction,
     distanceSortingSelectionAction,
     cancelAction]
  }
  
  // MARK: - Initialization
  
  required init(dependencies: ViewModel.Dependencies) {
    viewModel = SortingOrientationSelectionViewModel(dependencies: dependencies)
    
    super.init(nibName: nil, bundle: nil)
    title = R.string.localizable.select_list_type().capitalized
    message = nil
    
    setCheckmarkForOption(with: viewModel.dependencies.selectedOptionValue)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Functions
  
  private func setCheckmarkForOption(with value: SortingOrientationValue) {
    var action: UIAlertAction
    
    switch viewModel.dependencies.selectedOptionValue {
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
