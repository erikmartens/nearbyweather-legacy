//
//  Constants+Theme.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 09.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit.UIColor

extension Constants {
  enum Theme {}
}

extension Constants.Theme {
  enum Color {}
}

extension Constants.Theme.Color {
  
  enum BrandColors {
    
    static var standardDay: UIColor {
      UIColor.from(dark: .init(hex: 0x64aff5),
                   light: .init(hex: 0x50B4FA))
    }
    
    static var standardNight: UIColor {
      UIColor.from(dark: .init(hex: 0x3f709b),
                   light: .init(hex: 0x32719C))
    }
  }
  
  enum InteractableElement {
    
    static var standardButton: UIColor {
      Constants.Theme.Color.BrandColors.standardDay
    }
    
    static var standardTint: UIColor {
      Constants.Theme.Color.BrandColors.standardDay
    }
  }
  
  enum ContentElement {
    
    static var title: UIColor {
      UIColor.from(dark: .init(hex: 0xFFFFFF),
                   light: .init(hex: 0x000000))
    }
    
    static var subtitle: UIColor {
      UIColor.from(dark: .init(hex: 0xC0C0C0),
                   light: .init(hex: 0x808080))
    }
  }
}
