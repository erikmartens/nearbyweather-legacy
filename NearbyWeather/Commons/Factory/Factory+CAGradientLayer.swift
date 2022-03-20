//
//  Factory+CAGradientLayer.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import QuartzCore.CAGradientLayer
import UIKit

extension Factory {
  
  struct GradientLayer: FactoryFunction {
    
    enum GradientLayerType {
      case weatherCell(frame: CGRect, cornerRadiusWeight: Weight, baseColor: UIColor)
    }
    
    typealias InputType = GradientLayerType
    typealias ResultType = CAGradientLayer
    
    static func make(fromType type: InputType) -> ResultType {
      let gardientLayer = CAGradientLayer()
      
      switch type {
      case let .weatherCell(frame, cornerRadiusWeight, baseColor):
        gardientLayer.frame = frame
        gardientLayer.cornerRadius = Constants.Dimensions.CornerRadius.from(weight: cornerRadiusWeight)
        gardientLayer.colors = [
          (baseColor.lighten(by: 10) ?? baseColor).cgColor,
          baseColor.cgColor,
          (baseColor.darken(by: 25) ?? baseColor).cgColor
        ]
      }
      
      return gardientLayer
    }
  }
}
