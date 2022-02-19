//
//  Factory+CAShapeLayer.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 10.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import QuartzCore.CAShapeLayer

extension Factory {
  
  struct ShapeLayer: FactoryFunction {
    
    enum ShapeLayerType {
      case circle(radius: CGFloat, borderWidth: CGFloat)
      case speechBubble(size: CGSize, radius: CGFloat, borderWidth: CGFloat, margin: CGFloat, triangleHeight: CGFloat)
    }
    
    typealias InputType = ShapeLayerType
    typealias ResultType = CAShapeLayer
    
    static func make(fromType type: InputType) -> ResultType {
      let shapeLayer = CAShapeLayer()
      
      switch type {
      case let .circle(radius, borderWidth):
        shapeLayer.path = Factory.BezierPath.make(fromType: .circle(radius: radius, borderWidth: borderWidth)).cgPath
        shapeLayer.frame.size = CGSize(width: radius*2, height: radius*2)
        shapeLayer.lineWidth = borderWidth/2
      case let .speechBubble(size, radius, borderWidth, margin, triangleHeight):
        shapeLayer.path = Factory.BezierPath.make(fromType: .speechBubble(
          size: size,
          radius: radius,
          borderWidth: borderWidth,
          margin: margin,
          triangleHeight: triangleHeight
        )).cgPath
      }
      
      return shapeLayer
    }
  }
}
