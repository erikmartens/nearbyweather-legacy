//
//  Factory+UIBezierPath.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 10.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import UIKit.UIBezierPath

extension Factory {
  
  struct BezierPath: FactoryFunction {
    
    enum BezierPathType {
      case circle(radius: CGFloat, borderWidth: CGFloat)
      case speechBubble(size: CGSize, radius: CGFloat, borderWidth: CGFloat, margin: CGFloat, triangleHeight: CGFloat)
    }
    
    typealias InputType = BezierPathType
    typealias ResultType = UIBezierPath
    
    static func make(fromType type: InputType) -> ResultType {
      switch type {
      case let .circle(radius, borderWidth):
        return UIBezierPath(
          arcCenter: CGPoint(x: radius, y: radius),
          radius: CGFloat(radius - borderWidth/2),
          startAngle: 0,
          endAngle: CGFloat.pi * 2,
          clockwise: true
        )
      case let .speechBubble(size, radius, borderWidth, margin, triangleHeight):
        let path = UIBezierPath()
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height).offsetBy(dx: 0, dy: -size.height/2)
        let radiusBorderAdjusted = radius - borderWidth/2
        
        path.move(to: CGPoint(x: rect.width/2, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.width/2 - triangleHeight*0.75, y: rect.maxY - triangleHeight))
        path.addArc(withCenter: CGPoint(x: rect.minX + radiusBorderAdjusted + margin/4, y: rect.maxY - radiusBorderAdjusted - triangleHeight), radius: radiusBorderAdjusted, startAngle: CGFloat(CGFloat.pi/2), endAngle: CGFloat(CGFloat.pi), clockwise: true)
        path.addArc(withCenter: CGPoint(x: rect.minX + radiusBorderAdjusted + margin/4, y: rect.minY + radiusBorderAdjusted + margin/4), radius: radiusBorderAdjusted, startAngle: CGFloat(CGFloat.pi), endAngle: CGFloat(-CGFloat.pi/2), clockwise: true)
        path.addArc(withCenter: CGPoint(x: rect.maxX - radiusBorderAdjusted - margin/4, y: rect.minY + radiusBorderAdjusted + margin/4), radius: radiusBorderAdjusted, startAngle: CGFloat(-CGFloat.pi/2), endAngle: 0, clockwise: true)
        path.addArc(withCenter: CGPoint(x: rect.maxX - radiusBorderAdjusted - margin/4, y: rect.maxY - radiusBorderAdjusted - triangleHeight), radius: radiusBorderAdjusted, startAngle: 0, endAngle: CGFloat(CGFloat.pi/2), clockwise: true)
        path.addLine(to: CGPoint(x: rect.width/2 + triangleHeight*0.75, y: rect.maxY - triangleHeight))
        path.close()
        
        return path
      }
    }
  }
}
