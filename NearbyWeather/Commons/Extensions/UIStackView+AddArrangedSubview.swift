//
//  UIStackView+AddArrangedSubview.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 05.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import UIKit.UIStackView

extension UIStackView {
  
  func addArrangedSubview<T: UIView>(_ subview: T, constraints: [NSLayoutConstraint]) {
    subview.translatesAutoresizingMaskIntoConstraints = false
    addArrangedSubview(subview)
    NSLayoutConstraint.activate(constraints)
  }
  
  func insertArrangedSubview<T: UIView>(_ subview: T, at index: Int, constraints: [NSLayoutConstraint]) {
    subview.translatesAutoresizingMaskIntoConstraints = false
    insertArrangedSubview(subview, at: index)
    NSLayoutConstraint.activate(constraints)
  }
}
