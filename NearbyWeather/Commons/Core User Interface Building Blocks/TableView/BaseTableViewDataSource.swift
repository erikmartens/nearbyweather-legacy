//
//  TableViewDataSource.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 02.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BaseTableViewDataSource: NSObject {
  weak var cellEditingDelegate: BaseTableViewDataSourceEditingDelegate?
  var sectionDataSources: BehaviorRelay<[TableViewSectionDataProtocol]?> = BehaviorRelay(value: nil)
  
  init(cellEditingDelegate: BaseTableViewDataSourceEditingDelegate? = nil) {
    self.cellEditingDelegate = cellEditingDelegate
  }
}

extension BaseTableViewDataSource: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    sectionDataSources.value?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    sectionDataSources.value?[safe: section]?.sectionCellsCount ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cellIdentifier = sectionDataSources.value?[safe: indexPath.section]?.sectionCellsIdentifiers?[safe: indexPath.row] else {
      fatalError("Could not determine reuse-identifier for sections-cells.")
    }
    guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BaseCellProtocol else {
      fatalError("Cell does not conform to the correct protocol (BaseCellProtocol).")
    }
    cell.configure(with: sectionDataSources[indexPath])
    return cell
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    sectionDataSources.value?[safe: section]?.sectionHeaderTitle
  }
  
  func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    sectionDataSources.value?[safe: section]?.sectionFooterTitle
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    sectionDataSources.value?[safe: indexPath.section]?.sectionItems[safe: indexPath.row]?.canEditRow ?? false
  }
  
  func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    sectionDataSources.value?[safe: indexPath.section]?.sectionItems[safe: indexPath.row]?.canMoveRow ?? false
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    cellEditingDelegate?.didCommitEdit(with: editingStyle, forRowAt: indexPath)
  }
  
  func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    cellEditingDelegate?.didMoveRow(at: sourceIndexPath, to: destinationIndexPath)
  }
}
