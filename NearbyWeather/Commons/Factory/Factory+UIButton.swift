//
//  Factory+UIButton.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 12.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit.UIButton

extension Factory {

  struct Button: FactoryFunction {

    enum ButtonType {
      case standard(title: String? = nil, height: CGFloat)
      case plain(title: String? = nil)
    }

    typealias InputType = ButtonType
    typealias ResultType = UIButton

    static func make(fromType type: InputType) -> ResultType {
      let button = UIButton()

      switch type {
      case let .standard(title, height):
        button.layer.cornerRadius = height/4
        button.layer.backgroundColor = Constants.Theme.Color.InteractableElement.standardButtonBackground.cgColor

        button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        button.setTitleColor(.white, for: UIControl.State())

        if let title = title {
          button.setTitle(title, for: UIControl.State())
        }
        
      case let .plain(title):
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        button.setTitleColor(Constants.Theme.Color.ViewElement.Label.titleLight, for: UIControl.State())
        
        if let title = title {
          button.setTitle(title, for: UIControl.State())
        }
      }

      return button
    }
  }
}
