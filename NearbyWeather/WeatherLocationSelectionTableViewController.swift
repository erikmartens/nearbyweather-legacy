//
//  OWMCityFilterTableViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 07.01.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import PKHUD

final class WeatherLocationSelectionTableViewController: UITableViewController {
  
  // MARK: - Routing
  
  weak var stepper: SettingsStepper?
  
  // MARK: - Properties
  
  private let searchController = UISearchController(searchResultsController: nil)
  private var filteredCities = [WeatherStationDTO]()
  
  // MARK: - ViewController Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.delegate = self
    searchController.delegate = self
    
    tableView.register(UINib(nibName: R.nib.singleLabelCell.name, bundle: R.nib.singleLabelCell.bundle),
                       forCellReuseIdentifier: R.reuseIdentifier.singleLabelCell.identifier)
    
    searchController.searchResultsUpdater = self
    searchController.searchBar.placeholder = R.string.localizable.search_by_name()
    searchController.hidesNavigationBarDuringPresentation = false
    searchController.dimsBackgroundDuringPresentation = false
    tableView.tableHeaderView = searchController.searchBar
    definesPresentationContext = true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.navigationBar.styleStandard()
    
    tableView.reloadData()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    DispatchQueue.main.async {
      self.searchController.searchBar.becomeFirstResponder()
    }
  }
  
  // MARK: - TableViewDataSource
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return filteredCities.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.singleLabelCell.identifier, for: indexPath) as! SingleLabelCell
    cell.contentLabel.text = "\(filteredCities[indexPath.row].name), \(filteredCities[indexPath.row].country)"
    return cell
  }
  
  // MARK: - TableViewDelegate
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    WeatherDataManager.shared.bookmarkedLocations.append(filteredCities[indexPath.row])
    HUD.flash(.success, delay: 1.0)
    navigationController?.popViewController(animated: true)
  }
  
}

extension WeatherLocationSelectionTableViewController: UISearchResultsUpdating {
  
  func updateSearchResults(for searchController: UISearchController) {
    guard let searchText = searchController.searchBar.text else {
      filteredCities = [WeatherStationDTO]()
      tableView.reloadData()
      return
    }
    WeatherLocationService.shared.locations(forSearchString: searchText, completionHandler: { [unowned self] weatherLocationDTOs in
      if let weatherLocationDTOs = weatherLocationDTOs {
        self.filteredCities = weatherLocationDTOs
      }
      DispatchQueue.main.async {
        self.tableView.reloadData()
      }
    })
  }
}

extension WeatherLocationSelectionTableViewController: UISearchControllerDelegate {
  
  func didDismissSearchController(_ searchController: UISearchController) {
    filteredCities = [WeatherStationDTO]()
    tableView.reloadData()
  }
}
