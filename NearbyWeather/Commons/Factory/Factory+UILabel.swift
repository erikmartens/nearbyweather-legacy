//
//  Factory+UILabel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 13.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit.UILabel

extension Factory {
  
  struct Label: FactoryFunction {
    
    enum LabelType {
      case title(alignment: NSTextAlignment, numberOfLines: Int)
      case body(alignment: NSTextAlignment, numberOfLines: Int)
      case description(alignment: NSTextAlignment, numberOfLines: Int)
    }
    
    typealias InputType = LabelType
    typealias ResultType = UILabel
    
    static func make(fromType type: InputType) -> ResultType {
      let label = UILabel()
      
      switch type {
      case let .title(alignment, numberOfLines):
        label.textColor = Constants.Theme.Color.ContentElement.title
        label.font = .preferredFont(forTextStyle: .title3)
        label.textAlignment = alignment
        label.numberOfLines = numberOfLines
      case let .body(alignment, numberOfLines):
        label.textColor = Constants.Theme.Color.ContentElement.title
        label.font = .preferredFont(forTextStyle: .body)
        label.textAlignment = alignment
        label.numberOfLines = numberOfLines
      case let .description(alignment, numberOfLines):
        label.textColor = Constants.Theme.Color.ContentElement.subtitle
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textAlignment = alignment
        label.numberOfLines = numberOfLines
      }
      
      return label
    }
  }
}
