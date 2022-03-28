//
//  BaseViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

protocol BaseViewController {
  associatedtype ViewModel: BaseViewModel
  var viewModel: ViewModel { get }
  init(dependencies: ViewModel.Dependencies)
  func setupBindings()
  func destroyBindings()
  func bindContentFromViewModel(_ viewModel: ViewModel)
  func bindUserInputToViewModel(_ viewModel: ViewModel)
}

/// functions are optional
extension BaseViewController {
  func setupBindings() {
    viewModel.observeEvents()
    bindContentFromViewModel(viewModel)
    bindUserInputToViewModel(viewModel)
  }
  
  func bindContentFromViewModel(_ viewModel: ViewModel) {}
  func bindUserInputToViewModel(_ viewModel: ViewModel) {}
}
