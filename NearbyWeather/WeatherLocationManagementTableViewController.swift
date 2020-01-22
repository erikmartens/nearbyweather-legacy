//
//  WeatherLocationManagementTableViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 24.02.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import UIKit

class WeatherLocationManagementTableViewController: UITableViewController {
  
  // MARK: - Computed Properties
  
  private var editingEnabled: Bool {
    return WeatherDataManager.shared.bookmarkedLocations.count > 1
  }
  
  // MARK: - ViewController LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = R.string.localizable.manage_locations()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.navigationBar.styleStandard(withBarTintColor: .nearbyWeatherStandard, isTransluscent: false, animated: true)
    navigationController?.navigationBar.addDropShadow(offSet: CGSize(width: 0, height: 1), radius: 10)
    
    tableView.isEditing = true
  }
  
  // MARK: - TableViewDelegate
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return WeatherDataManager.shared.bookmarkedLocations.count
    default:
      return 0
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.section {
    case 0:
      let cell = tableView.dequeueReusableCell(withIdentifier: "OWMCityCell", for: indexPath) as! LocationWeatherDataCell
      let location = WeatherDataManager.shared.bookmarkedLocations[indexPath.row]
      cell.contentLabel.text = "\(location.name), \(location.country)"
      cell.selectionStyle = .none
      return cell
    default:
      return UITableViewCell()
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
    return false
  }
  
  override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    
    defer {
      tableView.reloadData()
    }
    
    if editingStyle == .delete {
      guard editingEnabled else {
        presentLastBookmarkDeletionAlert()
        return
      }
      WeatherDataManager.shared.bookmarkedLocations.remove(at: indexPath.row)
    }
  }
  
  override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    let movedLocation = WeatherDataManager.shared.bookmarkedLocations[sourceIndexPath.row]
    WeatherDataManager.shared.bookmarkedLocations.remove(at: sourceIndexPath.row)
    WeatherDataManager.shared.bookmarkedLocations.insert(movedLocation, at: destinationIndexPath.row)
  }
  
  override func setEditing(_ editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: animated)
    tableView.reloadData()
  }
  
  // MARK: - Private Helpers
  
  private func presentLastBookmarkDeletionAlert() {
    let alert = UIAlertController(title: R.string.localizable.delete_last_bookmark_title().capitalized, message: R.string.localizable.delete_last_bookmark_message(), preferredStyle: .alert)
    
    let cancelAction = UIAlertAction(title: R.string.localizable.dismiss(), style: .cancel, handler: nil)
    alert.addAction(cancelAction)
    
    present(alert, animated: true, completion: nil)
  }
}
