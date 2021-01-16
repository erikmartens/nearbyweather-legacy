//
//  Factory+MKMapView.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 10.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import MapKit.MKMapView

extension Factory {
  
  struct MapView: FactoryFunction {
    
    enum MapViewType {
      case standard(frame: CGRect, cornerRadiusWeight: Weight? = nil)
    }
    
    typealias InputType = MapViewType
    typealias ResultType = MKMapView
    
    static func make(fromType type: InputType) -> ResultType {
      switch type {
      case let .standard(frame, cornerRadiusWeight):
        let mapView = MKMapView(frame: frame)
        if let cornerRadiusWeight = cornerRadiusWeight {
          mapView.layer.cornerRadius = Constants.Dimensions.Size.CornerRadiusSize.from(weight: cornerRadiusWeight)
        }
        mapView.showsUserLocation = true
        mapView.isUserInteractionEnabled = true
        mapView.backgroundColor = Constants.Theme.Color.ViewElement.primaryBackground
        return mapView
      }
    }
  }
}
