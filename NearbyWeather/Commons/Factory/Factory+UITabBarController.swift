//
//  Factory+UITabBarController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 30.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import UIKit.UITabBarController

extension Factory {
  
  struct TabBarController: FactoryFunction {
    
    enum TabBarControllerType {
      case standard
    }
    
    typealias InputType = TabBarControllerType
    typealias ResultType = UITabBarController
    
    static func make(fromType type: InputType) -> ResultType {
      let tabBarController = UITabBarController()
      let appearance = UITabBarAppearance()
      appearance.configureWithDefaultBackground()
      
      tabBarController.tabBar.standardAppearance = appearance
      tabBarController.tabBar.isTranslucent = true
      tabBarController.tabBar.barTintColor = Constants.Theme.Color.ViewElement.primaryBackground
      tabBarController.tabBar.tintColor = Constants.Theme.Color.MarqueColors.standardMarque
      
      switch type {
      case .standard:
        break
      }
      
      return tabBarController
    }
  }
}
