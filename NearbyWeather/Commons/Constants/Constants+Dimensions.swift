//
//  Constants+Dimensions.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 13.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit

enum Weight {
  case small
  case medium
  case large
  case extraLarge
}

extension Constants {
  enum Dimensions {}
}

extension Constants.Dimensions {
  
  enum ContentElement {
    /// constant: 34
    static let height: CGFloat = 34
  }
  
  enum InteractableElement {
    /// constant: 34
    static let height: CGFloat = 34
  }
  
  enum TableCellImage {
    /// constant: 28
    static let width: CGFloat = 28
    /// constant: 28
    static let height: CGFloat = 28
    /// constant: 4
    static let cornerRadius: CGFloat = 4
  }
  
  enum TableCellContentInsets {
    /// constant: 16
    static let leading: CGFloat = 16
    /// constant: 16
    static let trailing: CGFloat = 16
    /// constant: 4
    static let top: CGFloat = 12
    /// constant: 4
    static let bottom: CGFloat = 12
    /// values: 4, 8 or 12
    static func interElementYDistance(from weight: Weight) -> CGFloat {
      switch weight {
        /// constant: 4
      case .small:
        return 4
        /// constant: 8
      case .medium:
        return 8
        /// constant: 12
      case .large:
        return 12
        /// constant: 16
      case .extraLarge:
        return 16
      }
    }
    /// values: 8, 12 and 16
    static func interElementXDistance(from weight: Weight) -> CGFloat {
      switch weight {
        /// constant: 8
      case .small:
        return 8
        /// constant: 12
      case .medium:
        return 12
        /// constant: 16
      case .large:
        return 16
        /// constant: 20
      case .extraLarge:
        return 20
      }
    }
  }
  
  enum CornerRadius {
    /// values: 8, 12 and 16
    static func from(weight: Weight) -> CGFloat {
      switch weight {
        /// constant: 8
      case .small:
        return 8
        /// constant: 12
      case .medium:
        return 12
        /// constant: 16
      case .large:
        return 16
        /// constant: 20
      case .extraLarge:
        return 20
      }
    }
  }
  
  enum AppIconImage {
    /// constant: 75
    static let width: CGFloat = 75
    /// constant: 75
    static let height: CGFloat = 75
    /// constant: 13
    static let cornerRadius: CGFloat = 13
  }
}
