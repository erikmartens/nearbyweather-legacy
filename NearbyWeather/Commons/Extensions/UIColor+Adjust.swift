//
//  UIColor+Adjust.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import UIKit.UIColor

extension UIColor {
  
  func lighten(by percentage: CGFloat = 0.3) -> UIColor {
    adjust(by: abs(percentage) )
  }
  
  func darken(by percentage: CGFloat = 0.3) -> UIColor {
    adjust(by: -1 * abs(percentage))
  }
  
  private func adjust(by percentage: CGFloat = 0.3) -> UIColor {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
      return UIColor(red: min(red + percentage, 1.0),
                     green: min(green + percentage, 1.0),
                     blue: min(blue + percentage, 1.0),
                     alpha: alpha)
    }
    return self
  }
}
