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

protocol BaseMapViewDelegateProtocol {
  associatedtype AnnotationViewType: BaseAnnotationViewProtocol
  init(annotationSelectionDelegate: BaseMapViewSelectionDelegate, annotationViewType: AnnotationViewType.Type)
}

class BaseMapViewDelegate<AnnotationViewType: BaseAnnotationViewProtocol>: NSObject, MKMapViewDelegate, BaseMapViewDelegateProtocol {
  
  // MARK: - Properties
  
  weak var annotationSelectionDelegate: BaseMapViewSelectionDelegate?
  private let annotationViewType: AnnotationViewType.Type
  
  // MARK: - Events
  
  var dataSource: BehaviorRelay<MapAnnotationData?> = BehaviorRelay(value: nil)
  
  // MARK: - Initialization
  
  required init(annotationSelectionDelegate: BaseMapViewSelectionDelegate, annotationViewType: AnnotationViewType.Type) {
    self.annotationSelectionDelegate = annotationSelectionDelegate
    self.annotationViewType = annotationViewType
  }
  
  // MARK: - MKMapViewDelegate Functions
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard annotation as? MKUserLocation == nil else {
      return nil
    }
    
    guard let annotationIdentifier = dataSource.value?.annotationViewReuseIdentifier else {
      fatalError("Could not determine reuse-identifier for annotation views.")
    }
    let annotationView: BaseAnnotationViewProtocol

    if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? BaseAnnotationViewProtocol {
      annotationView = dequeuedAnnotationView
    } else {
      annotationView = AnnotationViewType(annotation: annotation, reuseIdentifier: AnnotationViewType.reuseIdentifier)
    }

    annotationView.configure(with: annotation as? BaseAnnotationViewModelProtocol)
    return annotationView
  }
}
