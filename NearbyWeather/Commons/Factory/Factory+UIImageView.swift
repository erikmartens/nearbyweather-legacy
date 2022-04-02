//
//  Factory+UIImageView.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 13.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit.UIImageView

extension Factory {
  
  struct ImageView: FactoryFunction {
    
    enum ImageViewType {
      case weatherConditionSymbol
      case symbol(systemImageName: String? = nil, tintColor: UIColor? = nil)
      case appIcon
      case cellPrefix
    }
    
    typealias InputType = ImageViewType
    typealias ResultType = UIImageView
    
    static func make(fromType type: InputType) -> ResultType {
      let imageView = UIImageView()
      
      switch type {
      case .weatherConditionSymbol:
        imageView.tintAdjustmentMode = .automatic
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
      case let .symbol(systemImageName, tintColor):
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        
        if let systemImageName = systemImageName {
          imageView.image = UIImage(
            systemName: systemImageName,
            withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)
          )?
            .trimmingTransparentPixels()?
            .withRenderingMode(.alwaysTemplate) ?? UIImage()
        } else {
          imageView.image = UIImage()
        }
        
        imageView.tintColor = tintColor ?? Constants.Theme.Color.ViewElement.WeatherInformation.colorBackgroundPrimaryTitle
      case .appIcon:
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = Constants.Dimensions.AppIconImage.cornerRadius
        imageView.layer.masksToBounds = true
      case .cellPrefix:
        imageView.tintColor = Constants.Theme.Color.ViewElement.cellPrefixSymbolImage
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
      }
      
      return imageView
    }
  }
}
