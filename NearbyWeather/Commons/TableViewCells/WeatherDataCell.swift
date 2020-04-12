//
//  WeatherDataCell.swift
//  SimpleWeather
//
//  Created by Erik Maximilian Martens on 03.12.16.
//  Copyright © 2016 Erik Maximilian Martens. All rights reserved.
//

import UIKit

class WeatherDataCell: UITableViewCell {
  
  var weatherDataIdentifier: Int!
  
  @IBOutlet weak var backgroundColorView: UIView!
  @IBOutlet weak var weatherConditionLabel: UILabel!
  @IBOutlet weak var cityNameLabel: UILabel!
  
  @IBOutlet weak var temperatureImageView: UIImageView!
  @IBOutlet weak var temperatureLabel: UILabel!
  
  @IBOutlet weak var cloudCoverImageView: UIImageView!
  @IBOutlet weak var cloudCoverageLabel: UILabel!
  
  @IBOutlet weak var humidityImageView: UIImageView!
  @IBOutlet weak var humidityLabel: UILabel!
  
  @IBOutlet weak var windSpeedImageView: UIImageView!
  @IBOutlet weak var windspeedLabel: UILabel!
  
  func configureWithWeatherDTO(_ weatherDTO: WeatherInformationDTO) {
    let bubbleColor: UIColor = ConversionWorker.isDayTime(for: weatherDTO.daytimeInformation, coordinates: weatherDTO.coordinates) ?? true
      ? Constants.Theme.BrandColors.standardDay
      : Constants.Theme.BrandColors.standardNight // default to blue colored cells
    
    weatherDataIdentifier = weatherDTO.cityID
    
    backgroundColorView.layer.cornerRadius = 5.0
    backgroundColorView.layer.backgroundColor = bubbleColor.cgColor
    
    cityNameLabel.textColor = .white
    cityNameLabel.font = .preferredFont(forTextStyle: .headline)
    
    temperatureImageView.tintColor = .white
    temperatureLabel.textColor = .white
    temperatureLabel.font = .preferredFont(forTextStyle: .subheadline)
    
    cloudCoverImageView.tintColor = .white
    cloudCoverageLabel.textColor = .white
    cloudCoverageLabel.font = .preferredFont(forTextStyle: .subheadline)
    
    humidityImageView.tintColor = .white
    humidityLabel.textColor = .white
    humidityLabel.font = .preferredFont(forTextStyle: .subheadline)
    
    windSpeedImageView.tintColor = .white
    windspeedLabel.textColor = .white
    windspeedLabel.font = .preferredFont(forTextStyle: .subheadline)
    
    let weatherConditionSymbol = ConversionWorker.weatherConditionSymbol(
      fromWeatherCode: weatherDTO.weatherCondition[0].identifier,
      isDayTime: ConversionWorker.isDayTime(for: weatherDTO.daytimeInformation, coordinates: weatherDTO.coordinates) ?? true
    )
    weatherConditionLabel.text = weatherConditionSymbol
    
    cityNameLabel.text = weatherDTO.cityName
    
    if let temperatureKelvin = weatherDTO.atmosphericInformation.temperatureKelvin {
      temperatureLabel.text = ConversionWorker.temperatureDescriptor(
        forTemperatureUnit: PreferencesDataService.shared.temperatureUnit,
        fromRawTemperature: temperatureKelvin
      )
    } else {
      temperatureLabel.text = nil
    }
    
    cloudCoverageLabel.text = weatherDTO.cloudCoverage.coverage?.append(contentsOf: "%", delimiter: .none)
    
    humidityLabel.text = weatherDTO.atmosphericInformation.humidity?.append(contentsOf: "%", delimiter: .none)
    
    if let windspeed = weatherDTO.windInformation.windspeed {
      windspeedLabel.text = ConversionWorker.windspeedDescriptor(
        forDistanceSpeedUnit: PreferencesDataService.shared.distanceSpeedUnit,
        forWindspeed: windspeed
      )
    } else {
      windspeedLabel.text = nil
    }
  }
}
