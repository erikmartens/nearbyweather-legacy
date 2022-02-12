//
//  Constants+Spacing.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 07.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit

extension Constants.Dimensions {
  enum Spacing {}
}

extension Constants.Dimensions.Spacing {
  
  enum ContentInsets {
    /// value: 8, 12, 16 or 20
    static func leading(from weight: Weight) -> CGFloat {
      switch weight {
      case .small:
        return 8
      case .medium:
        return 12
      case .large:
        return 16
      case .extraLarge:
        return 20
      }
    }
    /// value: 8, 12, 16 or 20
    static func trailing(from weight: Weight) -> CGFloat {
      switch weight {
      case .small:
        return 8
      case .medium:
        return 12
      case .large:
        return 16
      case .extraLarge:
        return 20
      }
    }
    /// value: 4, 8, 12 or 16
    static func top(from weight: Weight) -> CGFloat {
      switch weight {
      case .small:
        return 4
      case .medium:
        return 8
      case .large:
        return 12
      case .extraLarge:
        return 16
      }
    }
    /// value: 4, 8, 12 or 16
    static func bottom(from weight: Weight) -> CGFloat {
      switch weight {
      case .small:
        return 4
      case .medium:
        return 8
      case .large:
        return 12
      case .extraLarge:
        return 16
      }
    }
  }
  
  enum InterElementSpacing {
    /// values: 4, 8, 12 or 16
    static func yDistance(from weight: Weight) -> CGFloat {
      switch weight {
      case .small:
        return 4
      case .medium:
        return 8
      case .large:
        return 12
      case .extraLarge:
        return 16
      }
    }
    /// values: 8, 12, 16 or 20
    static func xDistance(from weight: Weight) -> CGFloat {
      switch weight {
      case .small:
        return 8
      case .medium:
        return 12
      case .large:
        return 16
      case .extraLarge:
        return 20
      }
    }
  }
}
