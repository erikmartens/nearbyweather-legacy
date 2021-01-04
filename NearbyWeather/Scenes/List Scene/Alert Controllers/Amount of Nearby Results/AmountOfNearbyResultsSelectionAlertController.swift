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
  
  typealias ViewModel = AmountOfNearbyResultsSelectionViewModel
  
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
    viewModel = AmountOfNearbyResultsSelectionViewModel(dependencies: dependencies)
    
    super.init(nibName: nil, bundle: nil)
    title = R.string.localizable.amount_of_results().capitalized
    message = nil
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
