//
//  MKMapView+Focus.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 05.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import MapKit.MKMapView

extension MKMapView {
  func focus(onCoordinate coordinate: CLLocationCoordinate2D?, latitudinalMeters: CLLocationDistance = 1500, longitudinalMeters: CLLocationDistance = 1500) {
    guard let coordinate = coordinate else {
      return
    }
    let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: latitudinalMeters, longitudinalMeters: longitudinalMeters)
    setRegion(region, animated: true)
  }
}
