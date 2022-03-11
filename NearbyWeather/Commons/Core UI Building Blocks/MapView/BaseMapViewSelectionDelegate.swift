//
//  BaseMapViewSelectionDelegate.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 10.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import MapKit

protocol BaseMapViewSelectionDelegate: AnyObject {
  func didSelectView(for annotationViewModel: BaseAnnotationViewModelProtocol)
}
