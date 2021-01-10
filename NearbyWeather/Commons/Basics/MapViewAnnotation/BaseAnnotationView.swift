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
  var annotationViewModel: AnnotationViewModel? { get set }
  func bindContentFromViewModel(_ annotationViewModel: AnnotationViewModel)
  func bindUserInputToViewModel(_ annotationViewModel: AnnotationViewModel)
}

/// functions are optional
extension BaseAnnotationView {
  func bindContentFromViewModel(_ annotationViewModel: AnnotationViewModel) {}
  func bindUserInputToViewModel(_ annotationViewModel: AnnotationViewModel) {}
}
