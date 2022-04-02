//
//  WeatherDataDTO.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 14.04.17.
//  Copyright © 2017 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import CoreLocation

/**
 * OWMWeatherDTO is used to parse the JSON response from the server
 * It is constructed in a way so that only the required information is parsed
 * This DTO therefore does not exactly mirror the server response
 */

struct WeatherInformationListDTO: Codable {
  var list: [WeatherInformationDTO]
  
  enum CodingKeys: String, CodingKey {
    case list
  }
}

struct WeatherInformationDTO: Codable, Equatable {

  struct CoordinatesDTO: Codable, Equatable {
    var latitude: Double?
    var longitude: Double?
    
    enum CodingKeys: String, CodingKey {
      case latitude = "lat"
      case longitude = "lon"
    }
    
    init(from decoder: Decoder) {
      let values = try? decoder.container(keyedBy: CodingKeys.self)
      
      latitude = try? values?.decodeIfPresent(Double.self, forKey: .latitude)
      longitude = try? values?.decodeIfPresent(Double.self, forKey: .longitude)
    }
  }
  
  struct WeatherConditionDTO: Codable, Equatable {
    var identifier: Int?
    var conditionName: String?
    var conditionDescription: String?
    var conditionIconCode: String?
    
    enum CodingKeys: String, CodingKey {
      case identifier = "id"
      case conditionName = "main"
      case conditionDescription = "description"
      case conditionIconCode = "icon"
    }
    
    init(from decoder: Decoder) {
      let values = try? decoder.container(keyedBy: CodingKeys.self)
      
      identifier = try? values?.decodeIfPresent(Int.self, forKey: .identifier)
      conditionName = try? values?.decodeIfPresent(String.self, forKey: .conditionName)
      conditionDescription = try? values?.decodeIfPresent(String.self, forKey: .conditionDescription)
      conditionIconCode = try? values?.decodeIfPresent(String.self, forKey: .conditionIconCode)
    }
  }
  
  struct AtmosphericInformationDTO: Codable, Equatable {
    var temperatureKelvin: Double?
    var feelsLikesTemperatureKelvin: Double?
    var temperatureKelvinHigh: Double?
    var temperatureKelvinLow: Double?
    var pressurePsi: Double?
    var humidity: Double?
    
    enum CodingKeys: String, CodingKey {
      case temperatureKelvin = "temp"
      case feelsLikesTemperatureKelvin = "feels_like"
      case temperatureKelvinHigh = "temp_max"
      case temperatureKelvinLow = "temp_min"
      case pressurePsi = "pressure"
      case humidity
    }
    
    init(from decoder: Decoder) {
      let values = try? decoder.container(keyedBy: CodingKeys.self)
      
      temperatureKelvin = try? values?.decodeIfPresent(Double.self, forKey: .temperatureKelvin)
      feelsLikesTemperatureKelvin = try? values?.decodeIfPresent(Double.self, forKey: .feelsLikesTemperatureKelvin)
      temperatureKelvinHigh = try? values?.decodeIfPresent(Double.self, forKey: .temperatureKelvinHigh)
      temperatureKelvinLow = try? values?.decodeIfPresent(Double.self, forKey: .temperatureKelvinLow)
      pressurePsi = try? values?.decodeIfPresent(Double.self, forKey: .pressurePsi)
      humidity = try? values?.decodeIfPresent(Double.self, forKey: .humidity)
    }
  }
  
  struct WindInformationDTO: Codable, Equatable {
    var windspeed: Double?
    var degrees: Double?
    
    enum CodingKeys: String, CodingKey {
      case windspeed = "speed"
      case degrees = "deg"
    }
    
    init(from decoder: Decoder) {
      let values = try? decoder.container(keyedBy: CodingKeys.self)
      
      windspeed = try? values?.decodeIfPresent(Double.self, forKey: .windspeed)
      degrees = try? values?.decodeIfPresent(Double.self, forKey: .degrees)
    }
  }
  
  struct CloudCoverageDTO: Codable, Equatable {
    var coverage: Double?
    
    enum CodingKeys: String, CodingKey {
      case coverage = "all"
    }
    
    init(from decoder: Decoder) {
      let values = try? decoder.container(keyedBy: CodingKeys.self)
      
      coverage = try? values?.decodeIfPresent(Double.self, forKey: .coverage)
    }
  }
  
  struct DayTimeInformationDTO: Codable, Equatable {
    /// multi location weather data does not contain this information
    
    var sunrise: Double?
    var sunset: Double?
    
    enum CodingKeys: String, CodingKey {
      case sunrise
      case sunset
    }
    
    init(from decoder: Decoder) {
      let values = try? decoder.container(keyedBy: CodingKeys.self)
      
      sunrise = try? values?.decodeIfPresent(Double.self, forKey: .sunrise)
      sunset = try? values?.decodeIfPresent(Double.self, forKey: .sunset)
    }
  }
  
  var stationIdentifier: Int
  var stationName: String
  var coordinates: CoordinatesDTO
  var weatherCondition: [WeatherConditionDTO]
  var atmosphericInformation: AtmosphericInformationDTO
  var windInformation: WindInformationDTO
  var cloudCoverage: CloudCoverageDTO
  var dayTimeInformation: DayTimeInformationDTO
  
  enum CodingKeys: String, CodingKey {
    case stationIdentifier = "id"
    case stationName = "name"
    case coordinates = "coord"
    case weatherCondition = "weather"
    case atmosphericInformation = "main"
    case windInformation = "wind"
    case cloudCoverage = "clouds"
    case dayTimeInformation = "sys"
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    self.stationIdentifier = try values.decode(Int.self, forKey: .stationIdentifier)
    self.stationName = try values.decode(String.self, forKey: .stationName)
    self.coordinates = try values.decode(CoordinatesDTO.self, forKey: .coordinates)
    self.weatherCondition = try values.decode([WeatherConditionDTO].self, forKey: .weatherCondition)
    self.atmosphericInformation = try values.decode(AtmosphericInformationDTO.self, forKey: .atmosphericInformation)
    self.windInformation = try values.decode(WindInformationDTO.self, forKey: .windInformation)
    self.cloudCoverage = try values.decode(CloudCoverageDTO.self, forKey: .cloudCoverage)
    self.dayTimeInformation = try values.decode(DayTimeInformationDTO.self, forKey: .dayTimeInformation)
  }
}
