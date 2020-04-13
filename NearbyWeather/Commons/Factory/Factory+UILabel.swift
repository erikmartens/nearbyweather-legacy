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
      case description
    }
    
    typealias InputType = LabelType
    typealias ResultType = UILabel
    
    static func make(fromType type: InputType) -> ResultType {
      let label = UILabel()
      
      switch type {
      case .standard:
        label.textColor = Constants.Theme.Color.ContentElement.title
        label.font = .preferredFont(forTextStyle: .body)
        label.textAlignment = .left
      case .description:
        label.textColor = Constants.Theme.Color.ContentElement.subtitle
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textAlignment = .right
      }
      
      return label
    }
  }
}
