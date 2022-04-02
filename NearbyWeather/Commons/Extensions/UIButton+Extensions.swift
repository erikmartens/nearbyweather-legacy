//
//  UIButton+Extensions.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 15.02.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import UIKit.UIButton

extension UIButton {
  
  func setIsRefreshing(_ isRefreshing: Bool) {
    let refreshControlTag = 1010
    
    if isRefreshing {
      titleLabel?.layer.opacity = 0
      
      let refreshSpinner = UIActivityIndicatorView(style: .medium)
      refreshSpinner.tag = refreshControlTag
      
      addSubview(refreshSpinner, constraints: [
        refreshSpinner.topAnchor.constraint(equalTo: topAnchor, constant: Constants.Dimensions.Spacing.InterElementSpacing.yDistance(from: .small)),
        refreshSpinner.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.Dimensions.Spacing.InterElementSpacing.yDistance(from: .small)),
        refreshSpinner.centerXAnchor.constraint(equalTo: centerXAnchor),
        refreshSpinner.widthAnchor.constraint(equalTo: refreshSpinner.heightAnchor)
      ])
      refreshSpinner.startAnimating()
      return
    }
    
    titleLabel?.layer.opacity = 1
    
    guard let refreshControl = viewWithTag(refreshControlTag) as? UIActivityIndicatorView else {
      return
    }
    refreshControl.stopAnimating()
    refreshControl.removeFromSuperview()
  }
  
}
