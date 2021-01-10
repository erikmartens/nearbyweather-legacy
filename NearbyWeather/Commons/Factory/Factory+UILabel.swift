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
      case title(alignment: NSTextAlignment = .left, numberOfLines: Int = 0)
      case body(alignment: NSTextAlignment = .left, numberOfLines: Int = 0)
      case description(alignment: NSTextAlignment = .left, numberOfLines: Int = 0)
      case weatherSymbol
      case mapAnnotation(fontSize: CGFloat, width: CGFloat, height: CGFloat, yOffset: CGFloat)
    }
    
    typealias InputType = LabelType
    typealias ResultType = UILabel
    
    static func make(fromType type: InputType) -> ResultType {
      let label = UILabel()
      
      switch type {
      case let .title(alignment, numberOfLines):
        label.textColor = Constants.Theme.Color.ViewElement.title
        label.font = .preferredFont(forTextStyle: .title3)
        label.textAlignment = alignment
        label.numberOfLines = numberOfLines
      case let .body(alignment, numberOfLines):
        label.textColor = Constants.Theme.Color.ViewElement.title
        label.font = .preferredFont(forTextStyle: .body)
        label.textAlignment = alignment
        label.numberOfLines = numberOfLines
      case let .description(alignment, numberOfLines):
        label.textColor = Constants.Theme.Color.ViewElement.subtitle
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textAlignment = alignment
        label.numberOfLines = numberOfLines
      case .weatherSymbol:
        label.font = .systemFont(ofSize: 70)
        label.textAlignment = .center
        label.numberOfLines = 1
      case let .mapAnnotation(fontSize, width, height, yOffset):
        label.frame.size = CGSize(width: width, height: height)
        label.frame = label.frame.offsetBy(dx: 0, dy: yOffset)
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.textAlignment = .center
        label.minimumScaleFactor = 0.8
        label.backgroundColor = .clear
      }
      
      return label
    }
  }
}
