//
//  WeatherInformationService2.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 29.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxSwift

final class WeatherInformationService2 {
  
  static let shared = WeatherInformationService2()
  
  // MARK: - Properties
  
  private lazy var persistencyWorker: RealmPersistencyWorker = {
    try! RealmPersistencyWorker(
      storageLocation: .documents,
      dataBaseFileName: "WeatherInformationDataBase"
    )
  }()
  
  private static let bookmarkedWeatherInformationCollection = "/weather_information/bookmarked/"
  private static let nearbyWeatherInformationCollection = "/weather_information/nearby/"
  
  // MARK: - Initialization
  
  init() {}
  
}
