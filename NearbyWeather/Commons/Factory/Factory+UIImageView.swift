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
      case symbol(image: UIImage)
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
      case let .symbol(image):
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.image = image
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
