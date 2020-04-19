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
      case cellImage
    }
    
    typealias InputType = ImageViewType
    typealias ResultType = UIImageView
    
    static func make(fromType type: InputType) -> ResultType {
      let imageView = UIImageView()
      
      switch type {
      case .cellImage:
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = Constants.Dimensions.TableCellImageSize.cornerRadius
      }
      
      return imageView
    }
  }
}
