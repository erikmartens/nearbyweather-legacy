//
//  Factory+UIBarButtonItem.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import UIKit.UIBarButtonItem

extension Factory {

  struct BarButtonItem: FactoryFunction {

    enum BarButtonItemType {
      case standard(title: String? = nil, image: UIImage? = nil, color: UIColor? = nil, style: UIBarButtonItem.Style = .plain)
      case systemImage(imageName: String, color: UIColor? = nil, paletteColors: [UIColor]?)
    }

    typealias InputType = BarButtonItemType
    typealias ResultType = UIBarButtonItem

    static func make(fromType type: InputType) -> ResultType {
      let button = UIBarButtonItem()
      
      switch type {
      case let .standard(title, image, color, style):
        button.title = title
        button.tintColor = color ?? Constants.Theme.Color.InteractableElement.standardBarButtonTint
        button.image = image?.withRenderingMode(.alwaysTemplate)
        button.style = style
      case let .systemImage(imageName, color, paletteColors):
        var imageConfig = UIImage.SymbolConfiguration(weight: .semibold)
          .applying(UIImage.SymbolConfiguration(scale: .large))
        
        if let paletteColors = paletteColors, !paletteColors.isEmpty {
          let colorConfig = UIImage.SymbolConfiguration(paletteColors: paletteColors)
          imageConfig = imageConfig.applying(colorConfig)
          button.image = UIImage(systemName: imageName, withConfiguration: imageConfig)?
            .withRenderingMode(.alwaysTemplate)
            .scalePreservingAspectRatio(targetScale: 90)
        } else {
          button.image = UIImage(systemName: imageName, withConfiguration: imageConfig)?
            .withTintColor(color ?? Constants.Theme.Color.InteractableElement.standardBarButtonTint, renderingMode: .alwaysOriginal)
            .scalePreservingAspectRatio(targetScale: 90)
        }
      }

      return button
    }
  }
}

// MARK: - Private Helper Extensions

private extension UIImage {
  
  func scalePreservingAspectRatio(targetScale: CGFloat) -> UIImage {
    let targetSize = CGSize(width: targetScale/UIScreen.main.scale, height: targetScale/UIScreen.main.scale)
    // Determine the scale factor that preserves aspect ratio
    let widthRatio = targetSize.width / size.width
    let heightRatio = targetSize.height / size.height
    
    let scaleFactor = min(widthRatio, heightRatio)
    
    // Compute the new image size that preserves aspect ratio
    let scaledImageSize = CGSize(
      width: size.width * scaleFactor,
      height: size.height * scaleFactor
    )
    
    // Draw and return the resized UIImage
    let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
    
    let scaledImage = renderer.image { _ in
      self.draw(in: CGRect(origin: .zero, size: scaledImageSize))
    }
    
    return scaledImage
  }
}
