//
//  UIViewController+Extensions.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 17.07.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import SafariServices

extension UIViewController {
  
  func presentSafariViewController(for url: URL) {
    let safariController = SFSafariViewController(url: url)
    safariController.preferredControlTintColor = Constants.Theme.Color.ViewElement.Label.titleLight
    safariController.modalPresentationStyle = .automatic
    present(safariController, animated: true, completion: nil)
  }
}
