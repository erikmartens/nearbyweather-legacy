//
//  Factory+UIImage.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 01.04.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import UIKit.UIImage

extension Factory {
  
  struct Image: FactoryFunction {
    
    enum ImageType {
      case cellSymbol(systemImageName: String?)
    }
    
    typealias InputType = ImageType
    typealias ResultType = UIImage
    
    static func make(fromType type: InputType) -> ResultType {
      switch type {
      case let .cellSymbol(systemImageName):
        guard let systemImageName = systemImageName else {
          return UIImage()
        }
        return UIImage(
          systemName: systemImageName,
          withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)
        )?
          .trimmingTransparentPixels()?
          .withRenderingMode(.alwaysTemplate) ?? UIImage()
      }
    }
  }
}
