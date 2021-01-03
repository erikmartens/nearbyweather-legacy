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
  
  typealias ViewModel = ListTypeSelectionViewModel
  
  // MARK: - Actions
  
  fileprivate lazy var nearbySelectionAction = Factory.AlertAction.make(fromType: .standard(title: ListTypeValue.nearby.title, handler: { [weak viewModel] _ in
    viewModel?.onDidSelectNearbySubject.onNext(())
  }))
  fileprivate lazy var bookmarksSelectionAction = Factory.AlertAction.make(fromType: .standard(title: ListTypeValue.bookmarked.title, handler: { [weak viewModel] _ in
    viewModel?.onDidSelectBookmarksSubject.onNext(())
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
    viewModel = ListTypeSelectionViewModel(dependencies: dependencies)
    
    super.init(nibName: nil, bundle: nil)
    title = R.string.localizable.select_list_type()
    message = nil
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
