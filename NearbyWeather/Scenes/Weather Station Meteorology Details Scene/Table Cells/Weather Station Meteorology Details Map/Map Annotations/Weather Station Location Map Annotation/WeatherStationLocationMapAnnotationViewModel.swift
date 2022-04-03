//
//  WeatherStationLocationMapAnnotationViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 01.04.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import MapKit
import RxSwift
import RxCocoa

// MARK: - Dependencies

extension WeatherStationLocationMapAnnotationViewModel {
  struct Dependencies {
    let coordinate: CLLocationCoordinate2D
  }
}

// MARK: - Class Definition

final class WeatherStationLocationMapAnnotationViewModel: NSObject, BaseAnnotationViewModel {
  
  // MARK: - Public Access
  
  var coordinate: CLLocationCoordinate2D {
    dependencies.coordinate
  }
  
  // MARK: - Assets
  
  // MARK: - Properties
  
  private let dependencies: Dependencies

  // MARK: - Events
  
  // MARK: - Drivers
  
  lazy var annotationModelDriver: Driver<WeatherStationLocationAnnotationModel> = Observable
    .just(WeatherStationLocationAnnotationModel(
      stationSymbol: Factory.Image.make(fromType: .symbol(systemImageName: "antenna.radiowaves.left.and.right", tintColor: Constants.Theme.Color.ViewElement.symbolImageDark)),
      tintColor: Constants.Theme.Color.ViewElement.symbolImageDark,
      backgroundColor: Constants.Theme.Color.ViewElement.symbolImageLight
    ))
    .asDriver(onErrorJustReturn: WeatherStationLocationAnnotationModel())

  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }
  
  // MARK: - Functions
  
  func observeEvents() {
    observeDataSource()
    observeUserTapEvents()
  }
}
