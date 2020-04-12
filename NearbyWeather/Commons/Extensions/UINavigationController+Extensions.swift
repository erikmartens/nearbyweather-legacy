//
//  UINavigationControllerExtensions.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 22.10.17.
//  Copyright © 2017 Erik Maximilian Martens. All rights reserved.
//

import UIKit

extension UIViewController {
  
  func addBarButton(atPosition position: UIBarButtonItem.Position, touchupInsideHandler handler: @escaping (() -> Void)) {
    let closeButton = UIBarButtonItem(image: R.image.verticalCloseButton(), style: .plain) { [unowned self] _ in
      self.view.endEditing(true)
      handler()
    }
    switch position {
    case .left:
      navigationItem.leftBarButtonItem = closeButton
    case .right:
      navigationItem.rightBarButtonItem = closeButton
    }
  }
}

extension UIBarButtonItem {
  enum Position {
    case left
    case right
  }
}

private class DynamicTarget {
  let closure: ((UIBarButtonItem) -> Void)
  
  init(closure: @escaping ((UIBarButtonItem) -> Void)) {
    self.closure = closure
  }
  
  @objc func invokeClosure(_ sender: UIBarButtonItem) {
    closure(sender)
  }
}

fileprivate extension UIBarButtonItem {
  convenience init(title: String?, style: UIBarButtonItem.Style, handler: @escaping ((UIBarButtonItem) -> Void)) {
    let dynamicTarget = DynamicTarget(closure: handler)
    self.init(title: title, style: style, target: dynamicTarget, action: #selector(DynamicTarget.invokeClosure(_:)))
    objc_setAssociatedObject(self, String(format: "[%d]", arc4random()), dynamicTarget, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
  }
  
  convenience init(image: UIImage?, style: UIBarButtonItem.Style, handler: @escaping ((UIBarButtonItem) -> Void)) {
    let dynamicTarget = DynamicTarget(closure: handler)
    self.init(image: image, style: style, target: dynamicTarget, action: #selector(DynamicTarget.invokeClosure(_:)))
    objc_setAssociatedObject(self, String(format: "[%d]", arc4random()), dynamicTarget, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
  }
}
