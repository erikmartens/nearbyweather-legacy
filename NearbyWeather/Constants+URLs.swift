//
//  Constants+URLs.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 31.01.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

extension Constants {
  
  enum Urls {
    static let kAppStoreRatingDeepLinkUrl = URL(string: "https://itunes.apple.com/app/id1227313069?action=write-review&mt=8")!
    static let kGitHubProjectMainPageUrl =  URL(string: "https://github.com/erikmartens/NearbyWeather")!
    static let kGitHubProjectContributionGuidelinesUrl = URL(string: "https://github.com/erikmartens/NearbyWeather/blob/master/CONTRIBUTING.md")!
    static let kGitHubProjectIssues = URL(string: "https://github.com/erikmartens/NearbyWeather/issues")!
    static let kPrivacyPolicyUrl = URL(string: "https://github.com/erikmartens/NearbyWeather/blob/master/PRIVACYPOLICY.md")!
    static let kOpenWeatherSingleLocationBaseUrl = URL(string: "http://api.openweathermap.org/data/2.5/weather")!
    static let kOpenWeatherMultiLocationBaseUrl = URL(string: "http://api.openweathermap.org/data/2.5/find")!
    static let kOpenWeatherMapUrl = URL(string: "https://openweathermap.org")!
    static let kOpenWeatherMapInstructionsUrl = URL(string: "https://openweathermap.org/appid")!
    static let kIconsEightUrl = URL(string: "https://www.icons8.com")!
    
    static func kOpenWeatherMapCityDetailsUrl(forCityWithName name: String) -> URL {
      return URL(string: "https://openweathermap.org/find?q=\(name)")!
    }
  }
}
