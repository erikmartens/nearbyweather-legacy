//
//  WeatherListViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 20.10.17.
//  Copyright © 2017 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import MapKit

enum ListType: CaseIterable {
  case bookmarked
  case nearby
  
  static var allCases: [ListType] {
    return [.bookmarked, .nearby]
  }
  
  var title: String {
    switch self {
    case .bookmarked:
      return R.string.localizable.bookmarked()
    case .nearby:
      return R.string.localizable.nearby()
    }
  }
}

final class WeatherListViewController: UITableViewController {
  
  // MARK: - Routing
  
  weak var stepper: WeatherListStepper?
  
  // MARK: Properties
  
  private var listType: ListType = .bookmarked {
    didSet {
      tableView.reloadData()
    }
  }
  
  // MARK: - ViewController Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBar.isHidden = false
    
    refreshControl = UIRefreshControl()
    tableView.separatorStyle = .none
    
    tableView.register(UINib(nibName: R.nib.weatherDataCell.name, bundle: R.nib.weatherDataCell.bundle),
                       forCellReuseIdentifier: R.reuseIdentifier.weatherDataCell.identifier)
    
    tableView.register(UINib(nibName: R.nib.alertCell.name, bundle: R.nib.alertCell.bundle),
                       forCellReuseIdentifier: R.reuseIdentifier.alertCell.identifier)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(Self.reconfigureOnWeatherDataServiceDidUpdate),
      name: Notification.Name(rawValue: Constants.Keys.NotificationCenter.kWeatherServiceDidUpdate),
      object: nil
    )
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    configure()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if UserDefaults.standard.value(forKey: Constants.Keys.UserDefaults.kIsInitialLaunch) == nil {
      UserDefaults.standard.set(false, forKey: Constants.Keys.UserDefaults.kIsInitialLaunch)
      updateWeatherData()
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    refreshControl?.endRefreshing()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Private Helpers
  
  private func configure() {
    navigationController?.navigationBar.styleStandard()
    
    configureLastRefreshDate()
    configureButtons()
    
    refreshControl?.addTarget(self, action: #selector(Self.updateWeatherData), for: .valueChanged)
  }
  
  @objc private func reconfigureOnWeatherDataServiceDidUpdate() {
    refreshControl?.endRefreshing()
    configureLastRefreshDate()
    configureButtons()
    tableView.reloadData()
  }
  
  private func configureLastRefreshDate() {
    guard let lastRefreshDate = UserDefaults.standard.object(forKey: Constants.Keys.UserDefaults.kWeatherDataLastRefreshDateKey) as? Date else {
      tableView.refreshControl?.attributedTitle = nil
      return
    }
    tableView.refreshControl?.attributedTitle = NSAttributedString(string:
      R.string.localizable.last_refresh_at(lastRefreshDate.shortDateTimeString)
    )
  }
  
  private func configureButtons() {
    if WeatherDataManager.shared.hasDisplayableData {
      navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.swap(), style: .plain, target: self, action: #selector(WeatherListViewController.listTypeBarButtonTapped(_:)))
    } else {
      navigationItem.leftBarButtonItem = nil
    }
  }
  
  @objc private func updateWeatherData() {
    refreshControl?.beginRefreshing()
    WeatherDataManager.shared.update(withCompletionHandler: nil)
  }
  
  // MARK: - IBActions
  
  @objc private func listTypeBarButtonTapped(_ sender: UIBarButtonItem) {
    let alert = Factory.AlertController.make(fromType:
      .weatherListType(currentListType: listType, completionHandler: { [weak self] selectedListType in
        self?.listType = selectedListType
      })
    )
    present(alert, animated: true, completion: nil)
  }
}

// MARK: - UITableViewDelegate

extension WeatherListViewController {
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    UITableView.automaticDimension
  }
  
  override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    CGFloat(100)
  }
}

// MARK: - UITableViewDataSource

extension WeatherListViewController {
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard !WeatherDataManager.shared.apiKeyUnauthorized else {
      return 1
    }
    switch listType {
    case .bookmarked:
      let numberOfRows = WeatherDataManager.shared.bookmarkedWeatherDataObjects?.count ?? 1
      return numberOfRows > 0 ? numberOfRows : 1
    case .nearby:
      guard UserLocationService.shared.locationPermissionsGranted else {
        return 1
      }
      let numberOfRows = WeatherDataManager.shared.nearbyWeatherDataObject?.weatherInformationDTOs?.count ?? 1
      return numberOfRows > 0 ? numberOfRows : 1
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let weatherCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.weatherDataCell.identifier, for: indexPath) as! WeatherDataCell
    let alertCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.alertCell.identifier, for: indexPath) as! AlertCell
    
    [weatherCell, alertCell].forEach {
      $0.backgroundColor = .clear
      $0.selectionStyle = .none
    }
    
    if WeatherDataManager.shared.apiKeyUnauthorized {
      let errorDataDTO = (WeatherDataManager.shared.bookmarkedWeatherDataObjects?.first { $0.errorDataDTO != nil})?.errorDataDTO ?? WeatherDataManager.shared.nearbyWeatherDataObject?.errorDataDTO
      alertCell.configureWithErrorDataDTO(errorDataDTO)
      return alertCell
    }
    
    switch listType {
    case .bookmarked:
      guard let bookmarkedWeatherDataObjects = WeatherDataManager.shared.bookmarkedWeatherDataObjects,
        !bookmarkedWeatherDataObjects.isEmpty else {
          alertCell.configure(with: R.string.localizable.empty_bookmarks_message())
          return alertCell
      }
      guard let weatherDTO = bookmarkedWeatherDataObjects[indexPath.row].weatherInformationDTO else {
        alertCell.configureWithErrorDataDTO(WeatherDataManager.shared.bookmarkedWeatherDataObjects?[indexPath.row].errorDataDTO)
        return alertCell
      }
      weatherCell.configureWithWeatherDTO(weatherDTO)
      return weatherCell
    case .nearby:
      if !UserLocationService.shared.locationPermissionsGranted {
        let errorDataDTO = ErrorDataDTO(errorType: ErrorType(value: .locationAccessDenied), httpStatusCode: nil)
        alertCell.configureWithErrorDataDTO(errorDataDTO)
        return alertCell
      }
      guard let nearbyWeatherDataObject = WeatherDataManager.shared.nearbyWeatherDataObject else {
        alertCell.configure(with: R.string.localizable.empty_nearby_locations_message())
        return alertCell
      }
      guard let weatherDTO = nearbyWeatherDataObject.weatherInformationDTOs?[indexPath.row] else {
        alertCell.configureWithErrorDataDTO(WeatherDataManager.shared.nearbyWeatherDataObject?.errorDataDTO)
        return alertCell
      }
      weatherCell.configureWithWeatherDTO(weatherDTO)
      return weatherCell
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard WeatherDataManager.shared.hasDisplayableData else {
      return
    }
    
    tableView.deselectRow(at: indexPath, animated: true)
    
    let selectedCell = tableView.cellForRow(at: indexPath) as? WeatherDataCell
    stepper?.requestRouting(toStep:
      WeatherListStep.weatherDetails(identifier: selectedCell?.weatherDataIdentifier)
    )
  }
}
