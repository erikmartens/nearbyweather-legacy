//
//  Factory+UITextField.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.02.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import UIKit.UITextField

extension Factory {

  struct TextField: FactoryFunction {

    enum ViewType {
      case standard(cornerRadiusWeight: Weight? = nil)
    }

    typealias InputType = ViewType
    typealias ResultType = UITextField

    static func make(fromType type: InputType) -> ResultType {
      
      switch type {
      case let .standard(cornerRadiusWeight):
        let textField = UITextField()
        if let cornerRadiusWeight = cornerRadiusWeight {
          textField.layer.cornerRadius = Constants.Dimensions.CornerRadius.from(weight: cornerRadiusWeight)
        }
        return textField
      }
    }
  }
}
