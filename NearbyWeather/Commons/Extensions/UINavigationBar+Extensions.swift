//
//  UINavigationBar+Extensions.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 18.10.17.
//  Copyright © 2017 Erik Maximilian Martens. All rights reserved.
//

import UIKit.UINavigationController

extension UINavigationBar {
  
  func styleStandard() {
    isTranslucent = false
    
    barTintColor = .white
    tintColor = .black
    titleTextAttributes = [.foregroundColor: UIColor.black]
    barStyle = .default
  }
  
  func style(withBarTintColor barTintColor: UIColor, tintColor: UIColor) {
    isTranslucent = false
    
    self.barTintColor = barTintColor
    self.tintColor = tintColor
    titleTextAttributes = [.foregroundColor: tintColor]
    barStyle = .default
  }
}
