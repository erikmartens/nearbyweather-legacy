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
      case standard(frame: CGRect, cornerRadiusWeight: Weight? = nil, showsUserLocation: Bool = true, isUserInteractionEnabled: Bool = true)
    }
    
    typealias InputType = MapViewType
    typealias ResultType = MKMapView
    
    static func make(fromType type: InputType) -> ResultType {
      switch type {
      case let .standard(frame, cornerRadiusWeight, showsUserLocation, isUserInteractionEnabled):
        let mapView = MKMapView(frame: frame)
        if let cornerRadiusWeight = cornerRadiusWeight {
          mapView.layer.cornerRadius = Constants.Dimensions.CornerRadius.from(weight: cornerRadiusWeight)
        }
        mapView.showsUserLocation = showsUserLocation
        mapView.isUserInteractionEnabled = isUserInteractionEnabled
        mapView.backgroundColor = Constants.Theme.Color.ViewElement.primaryBackground
        return mapView
      }
    }
  }
}
