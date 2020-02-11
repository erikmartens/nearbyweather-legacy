//
//  Date+String.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

extension Date {
  
  var shortDateTimeString: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
    
    return dateFormatter.string(from: self)
  }
}
