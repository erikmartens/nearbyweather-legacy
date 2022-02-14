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
      case standard(title: String? = nil, image: UIImage? = nil)
    }

    typealias InputType = BarButtonItemType
    typealias ResultType = UIBarButtonItem

    static func make(fromType type: InputType) -> ResultType {
      let button = UIBarButtonItem()
      button.style = .plain
      button.tintColor = Constants.Theme.Color.InteractableElement.standardBarButtonTint

      switch type {
      case let .standard(title, image):
        button.title = title
        button.image = image
      }

      return button
    }
  }
}
