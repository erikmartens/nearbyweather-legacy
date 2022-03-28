//
//  LoadingViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 13.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxSwift

// MARK: - Definitions

private extension LoadingViewController {
  struct Definitions {}
}

// MARK: - Class Definition

final class LoadingViewController: UIViewController, BaseViewController {
  
  typealias ViewModel = LoadingViewModel
  private typealias ContentInsets = Constants.Dimensions.Spacing.ContentInsets
  
  // MARK: - UIComponents
  
  fileprivate lazy var loadingSpinner = UIActivityIndicatorView(style: .large)
  
  // MARK: - Assets
  
  private var disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  let viewModel: ViewModel
  
  // MARK: - Initialization
  
  required init(dependencies: ViewModel.Dependencies) {
    viewModel = LoadingViewModel(dependencies: dependencies)
    super.init(nibName: nil, bundle: nil)
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
  
  // MARK: - ViewController LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel.viewDidLoad()
    setupUiComponents()
    setupBindings()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setupUiAppearance()
    loadingSpinner.startAnimating()
//    setupBindings()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    setupUiAppearance()
    loadingSpinner.stopAnimating()
//    destroyBindings()
  }
}

// MARK: - ViewModel Bindings

extension LoadingViewController {
  
  func setupBindings() {
    viewModel.observeEvents()
    bindContentFromViewModel(viewModel)
    bindUserInputToViewModel(viewModel)
  }
  
  func destroyBindings() {
    disposeBag = DisposeBag()
    viewModel.disregardEvents()
  }
  
  func bindContentFromViewModel(_ viewModel: ViewModel) {
    viewModel
      .titleDriver
      .drive(onNext: { [weak self] navigationTitle in self?.title = navigationTitle })
      .disposed(by: disposeBag)
  }
  
  func bindUserInputToViewModel(_ viewModel: ViewModel) {
    // nothing to do
  }
}

// MARK: - Setup

private extension LoadingViewController {
  
  func setupUiComponents() {
    
    view.addSubview(loadingSpinner, constraints: [
      loadingSpinner.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: ContentInsets.top(from: .large)),
      loadingSpinner.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -ContentInsets.bottom(from: .large) - (tabBarController?.tabBar.frame.size.height ?? 0)),
      loadingSpinner.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ContentInsets.leading(from: .large)),
      loadingSpinner.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -ContentInsets.trailing(from: .large)),
      loadingSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      loadingSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -(tabBarController?.tabBar.frame.size.height ?? 0))
    ])
  }
  
  func setupUiAppearance() {
    view.backgroundColor = Constants.Theme.Color.ViewElement.primaryBackground
  }
}
