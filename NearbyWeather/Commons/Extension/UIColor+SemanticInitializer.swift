//
//  UIColor+SemanticInitializer.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 09.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit.UIColor

extension UIColor {
  
  static func from(dark: UIColor, light: UIColor) -> UIColor {
    guard #available(iOS 13.0, *) else {
      return light
    }
    return UIColor { traitCollection in
      switch traitCollection.userInterfaceStyle {
      case .light:
        return light
      case .dark:
        return dark
      case .unspecified:
        return light
      @unknown default:
        return light
      }
    }
  }
  
  convenience init(red: Int, green: Int, blue: Int) {
    assert(red >= 0 && red <= 255, "Invalid red component")
    assert(green >= 0 && green <= 255, "Invalid green component")
    assert(blue >= 0 && blue <= 255, "Invalid blue component")
    
    self.init(
      red: CGFloat(red) / 255.0,
      green: CGFloat(green) / 255.0,
      blue: CGFloat(blue) / 255.0,
      alpha: 1.0
    )
  }
  
  convenience init(hex: Int) {
    self.init(
      red: (hex >> 16) & 0xFF,
      green: (hex >> 8) & 0xFF,
      blue: hex & 0xFF
    )
  }
}
