//
//  NetworkReachabilityService.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 15.02.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import Alamofire

// MARK: - Domain-Specific Errors

extension NetworkReachabilityService {
  enum DomainError: String, Error {
    var domain: String { "NetworkReachabilityService" }
    
    case reachabilityManagerUnavailableError = "Trying to instantiate AlamoFire.NetworkReachabilityManager, but it failed."
  }
}

// MARK: - Class Definition

final class NetworkReachabilityService {
  
  // MARK: - Properties
  
  // MARK: - Initialization
  
  init() {}
}

// MARK: - Network Reachability

protocol NetworkReachability {
  func createIsNetworkReachableObservable() -> Observable<Bool>
}

extension NetworkReachabilityService: NetworkReachability {
  
  func createIsNetworkReachableObservable() -> Observable<Bool> {
    Observable<Bool>
      .create { subscriber in
        guard let reachabilityManager = NetworkReachabilityManager() else {
          subscriber.on(.error(DomainError.reachabilityManagerUnavailableError))
          return Disposables.create()
        }
        
        reachabilityManager.listener = { status in
          switch status {
          case .unknown: subscriber.on(.next(false))
          case .notReachable: subscriber.on(.next(false))
          case .reachable(.ethernetOrWiFi), .reachable(.wwan): subscriber.on(.next(true))
          }
        }
        return Disposables.create()
      }
  }
}
