//
//  TableViewDelegate.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 02.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import UIKit

class BaseTableViewDelegate: NSObject {
  
  weak var cellSelectionDelegate: BaseTableViewSelectionDelegate?
  
  init(cellSelectionDelegate: BaseTableViewSelectionDelegate) {
    self.cellSelectionDelegate = cellSelectionDelegate
  }
}

extension BaseTableViewDelegate: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    UITableView.automaticDimension
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    cellSelectionDelegate?.didSelectRow(at: indexPath)
  }
}
