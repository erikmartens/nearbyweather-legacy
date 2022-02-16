//
//  Array<PersistencyModel<WeatherInformationDTO>>+MapToWeatherMapAnnotationViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 16.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import CoreLocation

extension Array where Element == PersistencyModelThreadSafe<WeatherInformationDTO> {
  
  func mapToWeatherMapAnnotationViewModel(
    weatherStationService: WeatherStationBookmarkReading,
    weatherInformationService: WeatherInformationReading,
    preferencesService: WeatherMapPreferenceReading,
    selectionDelegate: BaseMapViewSelectionDelegate?
  ) -> [BaseAnnotationViewModelProtocol] {
    compactMap { weatherInformationPersistencyModel -> WeatherMapAnnotationViewModel? in
      guard let latitude = weatherInformationPersistencyModel.entity.coordinates.latitude,
            let longitude = weatherInformationPersistencyModel.entity.coordinates.longitude else {
        return nil
      }
      return WeatherMapAnnotationViewModel(dependencies: WeatherMapAnnotationViewModel.Dependencies(
        weatherInformationIdentity: weatherInformationPersistencyModel.identity,
        coordinate: CLLocationCoordinate2D(
          latitude: latitude,
          longitude: longitude
        ),
        weatherStationService: weatherStationService,
        weatherInformationService: weatherInformationService,
        preferencesService: preferencesService,
        annotationSelectionDelegate: selectionDelegate
      ))
    }
  }
}
