//
//  Factory+UITableView.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import UIKit.UITableView

extension Factory {
  
  struct TableView: FactoryFunction {
    
    enum TableViewType {
      case standard(frame: CGRect, style: UITableView.Style = .insetGrouped)
    }
    
    typealias InputType = TableViewType
    typealias ResultType = UITableView
    
    static func make(fromType type: InputType) -> ResultType {
      switch type {
      case let .standard(frame, style):
        let tableView = UITableView(frame: frame, style: style)
        
        tableView.separatorStyle = .singleLine
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .clear
        
        return tableView
      }
    }
  }
}
