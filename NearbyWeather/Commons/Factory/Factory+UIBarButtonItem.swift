//
//  Factory+UIBarButtonItem.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import UIKit.UIBarButtonItem
import UIKit

extension Factory {

  struct BarButtonItem: FactoryFunction {

    enum BarButtonItemType {
      case standard(title: String? = nil, image: UIImage? = nil, color: UIColor? = nil, style: UIBarButtonItem.Style = .plain)
      case systemImage(imageName: String, color: UIColor? = nil)
      case systemImageWithCircle(imageName: String, paletteColors: [UIColor] = [], circleColor: UIColor? = nil)
    }

    typealias InputType = BarButtonItemType
    typealias ResultType = UIBarButtonItem

    static func make(fromType type: InputType) -> ResultType {
      let button = UIBarButtonItem()
      
      switch type {
      case let .standard(title, image, color, style):
        button.title = title
        button.tintColor = color ?? Constants.Theme.Color.MarqueColors.standardMarque
        button.image = image?.withRenderingMode(.alwaysTemplate)
        button.style = style
      case let .systemImage(imageName, color):
        let imageConfig = UIImage.SymbolConfiguration(weight: .semibold)
          .applying(UIImage.SymbolConfiguration(scale: .large))
        
        button.image = UIImage(systemName: imageName, withConfiguration: imageConfig)?
          .withTintColor(color ?? Constants.Theme.Color.MarqueColors.standardMarque, renderingMode: .alwaysOriginal)
      case let .systemImageWithCircle(imageName, paletteColors, circleColor):
        let frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        
        let circleView = UIView(frame: frame)
        let circleLayer = Factory.ShapeLayer.make(fromType: .circle(radius: frame.height/2, borderWidth: 0))
        circleLayer.fillColor = (circleColor ?? Constants.Theme.Color.SystemColor.gray).withAlphaComponent(0.2).cgColor
        circleView.layer.addSublayer(circleLayer)
        
        let imageView: UIImageView
        
        var imageConfig = UIImage.SymbolConfiguration(weight: .semibold)
        
        if !paletteColors.isEmpty, paletteColors.count > 1 {
          let colorConfig = UIImage.SymbolConfiguration(paletteColors: paletteColors)
          imageConfig = imageConfig.applying(colorConfig)
          
          imageView = UIImageView(frame: frame)
          imageView.image = UIImage(systemName: imageName, withConfiguration: colorConfig)?
            .withRenderingMode(.alwaysTemplate)
        } else {
          imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
          imageView.image = UIImage(systemName: imageName, withConfiguration: imageConfig)?
            .withTintColor(paletteColors[safe: 0] ?? Constants.Theme.Color.MarqueColors.standardMarque, renderingMode: .alwaysOriginal)
        }
        
        circleView.addSubview(imageView)
        imageView.center = circleView.center
        
        button.image = circleView.toImage()
      }
      
      return button
    }
  }
}

// MARK: - Private Helper Extensions

extension UIView {
  func toImage() -> UIImage {
    UIGraphicsImageRenderer(bounds: bounds).image { rendererContext in
      layer.render(in: rendererContext.cgContext)
    }
  }
}
