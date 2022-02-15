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
    
    titleLabel?.isHidden = isRefreshing
    if isRefreshing {
      let refreshSpinner = UIRefreshControl()
      refreshSpinner.tag = refreshControlTag
      
      addSubview(refreshSpinner, constraints: [
        refreshSpinner.topAnchor.constraint(equalTo: topAnchor, constant: Constants.Dimensions.Spacing.InterElementSpacing.yDistance(from: .small)),
        refreshSpinner.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.Dimensions.Spacing.InterElementSpacing.yDistance(from: .small)),
        refreshSpinner.widthAnchor.constraint(equalTo: refreshSpinner.heightAnchor)
      ])
      refreshSpinner.beginRefreshing()
      return
    }
    
    guard let refreshControl = viewWithTag(refreshControlTag) as? UIRefreshControl else {
      return
    }
    refreshControl.endRefreshing()
    refreshControl.removeFromSuperview()
  }
  
}
