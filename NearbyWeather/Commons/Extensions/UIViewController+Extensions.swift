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
    safariController.preferredControlTintColor = Constants.Theme.Color.ContentElement.title
    if #available(iOS 13, *) {
      safariController.modalPresentationStyle = .automatic
    } else {
      safariController.modalPresentationStyle = .overFullScreen
    }
    present(safariController, animated: true, completion: nil)
  }
}
