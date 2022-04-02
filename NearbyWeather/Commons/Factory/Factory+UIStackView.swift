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
      case vertical(alignment: UIStackView.Alignment = .fill, distribution: UIStackView.Distribution = .fill, spacingWeight: Weight? = nil)
      case horizontal(alignment: UIStackView.Alignment = .fill, distribution: UIStackView.Distribution = .fill, spacingWeight: Weight? = nil)
    }
    
    typealias InputType = StackViewType
    typealias ResultType = UIStackView
    
    static func make(fromType type: InputType) -> ResultType {
      let stackView = UIStackView()
      
      switch type {
      case let .vertical(alignment, distribution, spacingWeight):
        stackView.axis = .vertical
        stackView.distribution = distribution
        stackView.alignment = alignment
        if let spacingWeight = spacingWeight {
          stackView.spacing = Constants.Dimensions.Spacing.InterElementSpacing.yDistance(from: spacingWeight)
        }
      case let .horizontal(alignment, distribution, spacingWeight):
        stackView.axis = .horizontal
        stackView.distribution = distribution
        stackView.alignment = alignment
        if let spacingWeight = spacingWeight {
          stackView.spacing = Constants.Dimensions.Spacing.InterElementSpacing.xDistance(from: spacingWeight)
        }
      }
      
      return stackView
    }
  }
}
