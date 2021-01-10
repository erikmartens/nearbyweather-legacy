//
//  WeatherMapViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 10.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxSwift

// MARK: - Class Definition

final class WeatherMapViewController: UIViewController, BaseViewController {
  
  typealias ViewModel = WeatherMapViewModel
  
  // MARK: - UIComponents
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  let viewModel: ViewModel
  
  // MARK: - Initialization
  
  required init(dependencies: ViewModel.Dependencies) {
    viewModel = WeatherMapViewModel(dependencies: dependencies)
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - ViewController LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel.viewDidLoad()
    setupLayout()
    setupBindings()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setupAppearance()
  }
}

// MARK: - ViewModel Bindings

private extension WeatherMapViewController {
  
  func setupBindings() {
    viewModel.observeEvents()
    bindContentFromViewModel(viewModel)
    bindUserInputToViewModel(viewModel)
  }
  
  private func bindContentFromViewModel(_ viewModel: ViewModel) {
    
  }
  
  private func bindUserInputToViewModel(_ viewModel: ViewModel) {
    
  }
}

// MARK: - Setup

private extension WeatherMapViewController {
  
  func setupLayout() {
    
  }
  
  func setupAppearance() {
    view.backgroundColor = Constants.Theme.Color.ViewElement.primaryBackground
  }
}
