//
//  Factory+UIAlertAction.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import UIKit

extension Factory {
  
  struct AlertAction: FactoryFunction {
    
    enum AlertActionType {
      case standard(title: String, destructive: Bool = false, handler: ((UIAlertAction) -> Void)?)
      case image(title: String, systemImageName: String?, handler: ((UIAlertAction) -> Void)?)
      case cancel
    }
    
    typealias InputType = AlertActionType
    typealias ResultType = UIAlertAction
    
    static func make(fromType type: InputType) -> ResultType {
      switch type {
      case let .standard(title, destructive, handler):
        return UIAlertAction(title: title, style: (destructive ? .destructive : .default), handler: handler)
      case let .image(title, systemImageName, handler):
        let action = UIAlertAction(title: title, style: .default, handler: handler)
        
        let image: UIImage
        if let systemImageName = systemImageName {
          image = UIImage(
            systemName: systemImageName,
            withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)
          )?
            .trimmingTransparentPixels()?
            .withRenderingMode(.alwaysTemplate) ?? UIImage()
        } else {
          image = UIImage()
        }
        
        action.setValue(image, forKey: Constants.Keys.KeyValueBindings.kImage)
        return action
      case .cancel:
        return UIAlertAction(title: R.string.localizable.cancel(), style: .cancel)
      }
    }
  }
}
