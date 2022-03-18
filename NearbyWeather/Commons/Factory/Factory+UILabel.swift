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
      case headline(text: String? = nil, alignment: NSTextAlignment = .left, numberOfLines: Int = 0, textColor: UIColor = Constants.Theme.Color.ViewElement.Label.titleDark)
      case title(text: String? = nil, alignment: NSTextAlignment = .left, numberOfLines: Int = 0, textColor: UIColor = Constants.Theme.Color.ViewElement.Label.titleDark)
      case body(text: String? = nil, alignment: NSTextAlignment = .left, numberOfLines: Int = 0, textColor: UIColor = Constants.Theme.Color.ViewElement.Label.bodyDark)
      case subtitle(text: String? = nil, alignment: NSTextAlignment = .left, numberOfLines: Int = 0, textColor: UIColor = Constants.Theme.Color.ViewElement.Label.subtitleDark)
      case weatherSymbol
      case mapAnnotation(fontSize: CGFloat, width: CGFloat, height: CGFloat, yOffset: CGFloat)
    }
    
    typealias InputType = LabelType
    typealias ResultType = UILabel
    
    static func make(fromType type: InputType) -> ResultType {
      let label = UILabel()
      
      switch type {
      case let .headline(text, alignment, numberOfLines, textColor):
        label.textColor = textColor
        label.font = .preferredFont(forTextStyle: .headline)
        label.text = text
        label.textAlignment = alignment
        label.numberOfLines = numberOfLines
        label.lineBreakMode = numberOfLines == 1 ? .byTruncatingTail : .byWordWrapping
      case let .title(text, alignment, numberOfLines, textColor):
        label.textColor = textColor
        label.font = .preferredFont(forTextStyle: .title3)
        label.text = text
        label.textAlignment = alignment
        label.numberOfLines = numberOfLines
        label.lineBreakMode = numberOfLines == 1 ? .byTruncatingTail : .byWordWrapping
      case let .body(text, alignment, numberOfLines, textColor):
        label.textColor = textColor
        label.font = .preferredFont(forTextStyle: .body)
        label.text = text
        label.textAlignment = alignment
        label.numberOfLines = numberOfLines
        label.lineBreakMode = numberOfLines == 1 ? .byTruncatingTail : .byWordWrapping
      case let .subtitle(text, alignment, numberOfLines, textColor):
        label.textColor = textColor
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.text = text
        label.textAlignment = alignment
        label.numberOfLines = numberOfLines
        label.lineBreakMode = numberOfLines == 1 ? .byTruncatingTail : .byWordWrapping
      case .weatherSymbol:
        label.font = .systemFont(ofSize: 56)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
      case let .mapAnnotation(fontSize, width, height, yOffset):
        label.frame.size = CGSize(width: width, height: height)
        label.frame = label.frame.offsetBy(dx: 0, dy: yOffset)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.textAlignment = .center
        label.minimumScaleFactor = 0.8
        label.backgroundColor = .clear
      }
      
      return label
    }
  }
}
