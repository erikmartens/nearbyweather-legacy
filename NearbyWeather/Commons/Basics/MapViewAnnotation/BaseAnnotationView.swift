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
  func bindInputFromViewModel(_ annotationViewModel: AnnotationViewModel)
  func bindOutputToViewModel(_ annotationViewModel: AnnotationViewModel)
}
