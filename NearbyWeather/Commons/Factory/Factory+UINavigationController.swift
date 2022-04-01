//
//  Factory+NavigationController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit.UINavigationController

extension Factory {
  
  struct NavigationController: FactoryFunction {
    
    enum NavigationControllerType {
      case standard
      case standardTabbed(tabTitle: String? = nil, systemImageName: String? = nil)
    }
    
    typealias InputType = NavigationControllerType
    typealias ResultType = UINavigationController
    
    static func make(fromType type: InputType) -> ResultType {
      let navigationController = UINavigationController()
      
      let appearance = UINavigationBarAppearance()
      appearance.configureWithDefaultBackground()
      appearance.titleTextAttributes = [.foregroundColor: Constants.Theme.Color.ViewElement.Label.titleDark]
      appearance.buttonAppearance = UIBarButtonItemAppearance(style: .plain)
      
      navigationController.navigationBar.standardAppearance = appearance
      navigationController.navigationBar.barTintColor = Constants.Theme.Color.MarqueColors.standardMarque
      navigationController.navigationBar.tintColor = Constants.Theme.Color.MarqueColors.standardMarque
      navigationController.navigationBar.isTranslucent = true
      navigationController.navigationBar.barStyle = .default
      navigationController.navigationBar.scrollEdgeAppearance = .none
      
      switch type {
      case .standard:
        break
      case let .standardTabbed(tabTitle, systemImageName):
        navigationController.tabBarItem.title = tabTitle
        
        let tabImage: UIImage
        if let systemImageName = systemImageName {
          tabImage = UIImage(
            systemName: systemImageName,
            withConfiguration: UIImage.SymbolConfiguration(weight: .semibold).applying(UIImage.SymbolConfiguration(scale: .large))
          )?
            .trimmingTransparentPixels()?
            .withRenderingMode(.alwaysTemplate) ?? UIImage()
        } else {
          tabImage = UIImage()
        }
        navigationController.tabBarItem.image = tabImage
      }
      
      return navigationController
    }
  }
}
