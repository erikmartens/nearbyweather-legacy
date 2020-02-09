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
  
  enum BrandColors {
    
    static var standardDay: UIColor {
      UIColor.from(dark: .init(hex: 0x50B4FA),
                   light: .init(hex: 0x508AFA))
    }
    
    static var standardNight: UIColor {
      UIColor.from(dark: .init(hex: 0x32719C),
                   light: .init(hex: 0x222990))
    }
  }
  
  enum Interactables {
    
    static var standardButton: UIColor {
      Constants.Theme.BrandColors.standardDay
    }
    
    static var standardTint: UIColor {
      Constants.Theme.BrandColors.standardDay
    }
  }
  
  enum InterfaceComponents {
    
  }
}
