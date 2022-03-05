//
//  MKMapView+Focus.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 05.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import MapKit.MKMapView

extension MKMapView {
  
  func focus(onLocation location: CLLocation?, latitudinalMeters: CLLocationDistance = 1500, longitudinalMeters: CLLocationDistance = 1500) {
    focus(onLocation: location?.coordinate, latitudinalMeters: latitudinalMeters, longitudinalMeters: longitudinalMeters)
  }
  
  func focus(onLocation location: CLLocationCoordinate2D?, latitudinalMeters: CLLocationDistance = 1500, longitudinalMeters: CLLocationDistance = 1500) {
    guard let location = location else {
      return
    }
    let region = MKCoordinateRegion(center: location, latitudinalMeters: latitudinalMeters, longitudinalMeters: longitudinalMeters)
    setRegion(region, animated: true)
  }
}
