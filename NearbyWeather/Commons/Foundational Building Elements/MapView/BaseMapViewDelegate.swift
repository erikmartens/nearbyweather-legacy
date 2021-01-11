//
//  BaseMapViewDelegate.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 10.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import MapKit
import RxSwift
import RxCocoa

class BaseMapViewDelegate: NSObject {
  
  weak var annotationSelectionDelegate: BaseMapViewSelectionDelegate?
  
  var dataSource: BehaviorRelay<MapAnnotationData?> = BehaviorRelay(value: nil)
  
  init(annotationSelectionDelegate: BaseMapViewSelectionDelegate) {
    self.annotationSelectionDelegate = annotationSelectionDelegate
  }
}

extension BaseMapViewDelegate: MKMapViewDelegate {
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard let annotationIdentifier = dataSource.value?.annotationViewReuseIdentifier else {
      fatalError("Could not determine reuse-identifier for annotation views.")
    }
    guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? BaseAnnotationViewProtocol else {
      fatalError("AnnotationView does not conform to the correct protocol (BaseMapViewAnnotationViewProtocol).")
    }
    annotationView.configure(with: annotation as? BaseAnnotationViewModelProtocol)
    return annotationView
  }
}
