//
//  Factory+UILabel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 13.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit

extension Factory {
  
  struct Label: FactoryFunction {
    
    enum LabelType {
      case standard
    }
    
    typealias InputType = LabelType
    typealias ResultType = UILabel
    
    static func make(fromType type: InputType) -> ResultType {
      let label = UILabel()
      
      switch type {
      case .standard:
        label.font = .preferredFont(forTextStyle: .body)
      }
      
      return label
    }
  }
}
