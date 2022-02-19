//
//  MKAnnotationView+AnnotationViewReuseIdentifiable.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 10.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import Foundation

import MapKit.MKAnnotationView

protocol AnnotationViewReuseIdentifiable {
  static var reuseIdentifier: String { get }
}

extension AnnotationViewReuseIdentifiable {
  static var reuseIdentifier: String {
    String(describing: self)
  }
}

extension MKAnnotationView: AnnotationViewReuseIdentifiable {}
