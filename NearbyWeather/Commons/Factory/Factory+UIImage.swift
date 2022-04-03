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
      case symbol(systemImageName: String?, tintColor: UIColor? = nil, weight: UIImage.SymbolWeight = .semibold)
      case cellSymbol(systemImageName: String?)
      case weatherConditionSymbol(systemImageName: String?, colorPalette: [UIColor] = [])
    }
    
    typealias InputType = ImageType
    typealias ResultType = UIImage
    
    static func make(fromType type: InputType) -> ResultType {
      switch type {
      case let .symbol(systemImageName, tintColor, weight):
        guard let systemImageName = systemImageName else {
          return UIImage()
        }
        return UIImage(
          systemName: systemImageName,
          withConfiguration: UIImage.SymbolConfiguration(weight: weight)
        )?
          .withTintColor(tintColor ?? Constants.Theme.Color.ViewElement.cellPrefixSymbolImage, renderingMode: .alwaysOriginal) ?? UIImage()
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
      case let .weatherConditionSymbol(systemImageName, colorPalette):
        guard let systemImageName = systemImageName, !colorPalette.isEmpty else {
          return UIImage()
        }
        let image: UIImage?
        let imageConfiguration = UIImage.SymbolConfiguration(weight: .semibold).applying(UIImage.SymbolConfiguration(scale: .large))
        
        if colorPalette.count > 1 {
          image = UIImage(
            systemName: systemImageName,
            withConfiguration: UIImage.SymbolConfiguration(paletteColors: colorPalette).applying(imageConfiguration)
          )?
            .withRenderingMode(.alwaysTemplate)
        } else {
          image = UIImage(
            systemName: systemImageName,
            withConfiguration: imageConfiguration
          )?
            .withTintColor(colorPalette[safe: 0] ?? Constants.Theme.Color.ViewElement.WeatherInformation.white, renderingMode: .alwaysOriginal)
        }
        
        return image ?? UIImage()
      }
    }
  }
}
