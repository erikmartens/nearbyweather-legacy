//
//  BaseAnnotationView.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 10.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import Foundation

protocol BaseAnnotationView: BaseAnnotationViewProtocol {
  associatedtype AnnotationViewModel: BaseAnnotationViewModelProtocol
  var viewModel: AnnotationViewModel? { get set }
  func bindInputFromViewModel(_ viewModel: AnnotationViewModel)
  func bindOutputToViewModel(_ viewModel: AnnotationViewModel)
}

/// functions are optional
extension BaseAnnotationView {
  func bindInputFromViewModel(_ viewModel: AnnotationViewModel) {}
  func bindOutputToViewModel(_ viewModel: AnnotationViewModel) {}
}
