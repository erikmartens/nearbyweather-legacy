//
//  Factory+UIStackView.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 05.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import UIKit.UIStackView

extension Factory {
  
  struct StackView: FactoryFunction {
    
    enum StackViewType {
      case vertical(distribution: UIStackView.Distribution = .fill, alignment: UIStackView.Alignment = .fill, spacing: CGFloat = 0)
      case horizontal(distribution: UIStackView.Distribution = .fill, alignment: UIStackView.Alignment = .fill, spacing: CGFloat = 0)
    }
    
    typealias InputType = StackViewType
    typealias ResultType = UIStackView
    
    static func make(fromType type: InputType) -> ResultType {
      let stackView = UIStackView()
      
      switch type {
      case let .vertical(distribution, alignment, spacing):
        stackView.axis = .vertical
        stackView.distribution = distribution
        stackView.alignment = alignment
        stackView.spacing = spacing
      case let .horizontal(distribution, alignment, spacing):
        stackView.axis = .horizontal
        stackView.distribution = distribution
        stackView.alignment = alignment
        stackView.spacing = spacing
      }
      
      return stackView
    }
  }
}
