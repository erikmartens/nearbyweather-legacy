//
//  NetworkingService.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 10.02.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import Foundation
import Alamofire

enum NetworkingReachabilityStatus {
  case unknown
  case disconnected
  case connected
}

final class WeatherNetworkingService {
  
  private lazy var weatherFetchQueue: DispatchQueue = {
    return DispatchQueue(label: Constants.Labels.DispatchQueues.kWeatherFetchQueue, qos: .userInitiated, attributes: [.concurrent])
  }()
  
  // MARK: - Public Assets
  
  static var shared: WeatherNetworkingService!
  
  // MARK: - Properties
  
  private let reachabilityManager: NetworkReachabilityManager?
  private(set) var reachabilityStatus: NetworkingReachabilityStatus
  
  private var apiKey: String? {
    UserDefaults.standard.value(forKey: Constants.Keys.UserDefaults.kNearbyWeatherApiKeyKey) as? String
  }
  
  // MARK: - Initialization
  
  private init() {
    self.reachabilityManager = NetworkReachabilityManager()
    self.reachabilityStatus = .unknown
    
    beginListeningNetworkReachability()
  }
  
  deinit {
    reachabilityManager?.stopListening()
  }
  
  // MARK: - Private Methods
  
  func beginListeningNetworkReachability() {
    reachabilityManager?.listener = { status in
      switch status {
      case .unknown: self.reachabilityStatus = .unknown
      case .notReachable: self.reachabilityStatus = .disconnected
      case .reachable(.ethernetOrWiFi), .reachable(.wwan): self.reachabilityStatus = .connected
      }
      NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.Keys.NotificationCenter.kNetworkReachabilityChanged), object: self)
    }
    reachabilityManager?.startListening()
  }
  
  // MARK: - Public Methods
  
  static func instantiateSharedInstance() {
    shared = WeatherNetworkingService()
  }
  
  func fetchWeatherInformationForStation(withIdentifier identifier: Int, completionHandler: @escaping ((WeatherDataContainer) -> Void)) {
    
    guard let apiKey = self.apiKey else {
        let errorDataDTO = ErrorDataDTO(errorType: ErrorType(value: .malformedUrlError),
                                        httpStatusCode: nil)
        return completionHandler(WeatherDataContainer(locationId: identifier,
                                                      errorDataDTO: errorDataDTO,
                                                      weatherInformationDTO: nil))
    }
    
    Alamofire
      .request(
        Constants.Urls.kOpenWeatherMapSingleStationtDataRequestUrls(with: apiKey, stationIdentifier: identifier),
        method: .get,
        parameters: nil,
        encoding: JSONEncoding.default,
        headers: nil
      )
      .responseData(queue: weatherFetchQueue) { [weak self] response in
        guard let self = self,
          let data = response.result.value,
          response.result.error == nil else {
            let errorDataDTO = ErrorDataDTO(errorType: ErrorType(value: .httpError),
                                            httpStatusCode: response.response?.statusCode)
            return completionHandler(WeatherDataContainer(locationId: identifier,
                                                          errorDataDTO: errorDataDTO,
                                                          weatherInformationDTO: nil))
        }
        completionHandler(self.extractWeatherInformation(data, identifier: identifier))
    }
  }
  
  func fetchBulkWeatherInformation(completionHandler: @escaping (BulkWeatherDataContainer) -> Void) {
    let session = URLSession.shared
    
    guard let currentLatitude = UserLocationService.shared.currentLatitude, let currentLongitude = UserLocationService.shared.currentLongitude else {
      let errorDataDTO = ErrorDataDTO(errorType: ErrorType(value: .locationUnavailableError), httpStatusCode: nil)
      return completionHandler(BulkWeatherDataContainer(errorDataDTO: errorDataDTO, weatherInformationDTOs: nil))
    }
    guard let apiKey = self.apiKey,
      let requestURL = URL(
        string: "\(Constants.Urls.kOpenWeatherMultiLocationBaseUrl.absoluteString)?APPID=\(apiKey)&lat=\(currentLatitude)&lon=\(currentLongitude)&cnt=\(PreferencesManager.shared.amountOfResults.integerValue)"
      ) else {
        let errorDataDTO = ErrorDataDTO(errorType: ErrorType(value: .malformedUrlError), httpStatusCode: nil)
        return completionHandler(BulkWeatherDataContainer(errorDataDTO: errorDataDTO, weatherInformationDTOs: nil))
    }
    let request = URLRequest(url: requestURL)
    let dataTask = session.dataTask(with: request, completionHandler: { data, response, error in
      guard let receivedData = data, response != nil, error == nil else {
        let errorDataDTO = ErrorDataDTO(errorType: ErrorType(value: .httpError), httpStatusCode: (response as? HTTPURLResponse)?.statusCode)
        return completionHandler(BulkWeatherDataContainer(errorDataDTO: errorDataDTO, weatherInformationDTOs: nil))
      }
      completionHandler(self.extractBulkWeatherInformation(receivedData))
    })
    dataTask.resume()
  }
  
  // MARK: - Private Helpers
  
  private func extractWeatherInformation(_ data: Data, identifier: Int) -> WeatherDataContainer {
    do {
      guard let extractedData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyHashable],
        let httpStatusCode = extractedData["cod"] as? Int else {
          let errorDataDTO = ErrorDataDTO(errorType: ErrorType(value: .unparsableResponseError), httpStatusCode: nil)
          return WeatherDataContainer(locationId: identifier, errorDataDTO: errorDataDTO, weatherInformationDTO: nil)
      }
      guard httpStatusCode == 200 else {
        if httpStatusCode == 401 {
          let errorDataDTO = ErrorDataDTO(errorType: ErrorType(value: .unrecognizedApiKeyError), httpStatusCode: httpStatusCode)
          return WeatherDataContainer(locationId: identifier, errorDataDTO: errorDataDTO, weatherInformationDTO: nil)
        }
        let errorDataDTO = ErrorDataDTO(errorType: ErrorType(value: .httpError), httpStatusCode: httpStatusCode)
        return WeatherDataContainer(locationId: identifier, errorDataDTO: errorDataDTO, weatherInformationDTO: nil)
      }
      let weatherInformationDTO = try JSONDecoder().decode(WeatherInformationDTO.self, from: data)
      return WeatherDataContainer(locationId: identifier, errorDataDTO: nil, weatherInformationDTO: weatherInformationDTO)
    } catch {
      printDebugMessage(domain: String(describing: self),
                        message: "Error while extracting single-location-data json: \(error.localizedDescription)")
      let errorDataDTO = ErrorDataDTO(errorType: ErrorType(value: .jsonSerializationError), httpStatusCode: nil)
      return WeatherDataContainer(locationId: identifier, errorDataDTO: errorDataDTO, weatherInformationDTO: nil)
    }
  }
  
  private func extractBulkWeatherInformation(_ data: Data) -> BulkWeatherDataContainer {
    do {
      guard let extractedData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyHashable],
        let httpStatusCodeString = extractedData["cod"] as? String,
        let httpStatusCode = Int(httpStatusCodeString) else {
          let errorDataDTO = ErrorDataDTO(errorType: ErrorType(value: .unparsableResponseError), httpStatusCode: nil)
          return BulkWeatherDataContainer(errorDataDTO: errorDataDTO, weatherInformationDTOs: nil)
      }
      guard httpStatusCode == 200 else {
        if httpStatusCode == 401 {
          let errorDataDTO = ErrorDataDTO(errorType: ErrorType(value: .unrecognizedApiKeyError), httpStatusCode: httpStatusCode)
          return BulkWeatherDataContainer(errorDataDTO: errorDataDTO, weatherInformationDTOs: nil)
        }
        let errorDataDTO = ErrorDataDTO(errorType: ErrorType(value: .httpError), httpStatusCode: httpStatusCode)
        return BulkWeatherDataContainer(errorDataDTO: errorDataDTO, weatherInformationDTOs: nil)
      }
      let multiWeatherData = try JSONDecoder().decode(WeatherInformationArrayWrapper.self, from: data)
      return BulkWeatherDataContainer(errorDataDTO: nil, weatherInformationDTOs: multiWeatherData.list)
    } catch {
      printDebugMessage(domain: String(describing: self),
                        message: "NetworkingService: Error while extracting multi-location-data json: \(error.localizedDescription)")
      let errorDataDTO = ErrorDataDTO(errorType: ErrorType(value: .jsonSerializationError), httpStatusCode: nil)
      return BulkWeatherDataContainer(errorDataDTO: errorDataDTO, weatherInformationDTOs: nil)
    }
  }
}
