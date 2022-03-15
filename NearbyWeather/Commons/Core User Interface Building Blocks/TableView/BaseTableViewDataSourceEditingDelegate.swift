//
//  BaseDataSourceEditingDelegate.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 15.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import UIKit.UITableViewCell

protocol BaseTableViewDataSourceEditingDelegate: AnyObject {
  func didCommitEdit(with editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
  func didMoveRow(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
}

extension BaseTableViewDataSourceEditingDelegate {
  func didCommitEdit(with editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {}
  func didMoveRow(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {}
}
