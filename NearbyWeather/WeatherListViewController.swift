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

final class WeatherListViewController: UIViewController {
  
  // MARK: - Routing
  
  weak var stepper: WeatherListStepper?
  
  // MARK: - Properties
  
  private var refreshControl = UIRefreshControl()
  
  private var listType: ListType = .bookmarked
  
  // MARK: - Outlets
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var separatoLineViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var refreshDateLabel: UILabel!
  
  @IBOutlet weak var emptyListOverlayContainerView: UIView!
  @IBOutlet weak var emptyListImageView: UIImageView!
  @IBOutlet weak var emptyListTitleLabel: UILabel!
  @IBOutlet weak var emptyListDescriptionLabel: UILabel!
  
  @IBOutlet weak var reloadButton: UIButton!
  
  // MARK: - ViewController Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.delegate = self
    tableView.dataSource = self
    
    tableView.register(UINib(nibName: R.nib.weatherDataCell.name, bundle: R.nib.weatherDataCell.bundle),
                       forCellReuseIdentifier: R.reuseIdentifier.weatherDataCell.identifier)
    
    tableView.register(UINib(nibName: R.nib.alertCell.name, bundle: R.nib.alertCell.bundle),
                       forCellReuseIdentifier: R.reuseIdentifier.alertCell.identifier)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    configure()
    tableView.reloadData()
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(WeatherListViewController.reconfigureOnWeatherDataServiceDidUpdate),
      name: Notification.Name(rawValue: Constants.Keys.NotificationCenter.kWeatherServiceDidUpdate),
      object: nil
    )
    
    if !WeatherDataManager.shared.hasDisplayableData {
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(WeatherListViewController.reconfigureOnNetworkDidBecomeAvailable),
        name: Notification.Name(rawValue: Constants.Keys.NotificationCenter.kNetworkReachabilityChanged),
        object: nil
      )
    }
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
    
    refreshControl.endRefreshing()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Private Helpers
  
  private func configure() {
    navigationItem.title = navigationItem.title?.capitalized
    
    navigationController?.navigationBar.styleStandard()
    
    configureLastRefreshDate()
    configureButtons()
    configureWeatherDataUnavailableElements()
    
    refreshControl.addTarget(self, action: #selector(WeatherListViewController.updateWeatherData), for: .valueChanged)
    tableView.addSubview(refreshControl)
    
    tableView.isHidden = !WeatherDataManager.shared.hasDisplayableData
    emptyListOverlayContainerView.isHidden = WeatherDataManager.shared.hasDisplayableData
    
    separatoLineViewHeightConstraint.constant = 1/UIScreen.main.scale
  }
  
  @objc private func reconfigureOnWeatherDataServiceDidUpdate() {
    configureLastRefreshDate()
    configureButtons()
    tableView.isHidden = !WeatherDataManager.shared.hasDisplayableData
    tableView.reloadData()
  }
  
  @objc private func reconfigureOnNetworkDidBecomeAvailable() {
    UIView.animate(withDuration: 0.5) {
      self.reloadButton.isHidden = WeatherNetworkingService.shared.reachabilityStatus != .connected
    }
  }
  
  private func configureWeatherDataUnavailableElements() {
    emptyListImageView.tintColor = .lightGray
    emptyListTitleLabel.text = R.string.localizable.no_weather_data()
    emptyListDescriptionLabel.text = R.string.localizable.no_data_description()
  }
  
  private func configureLastRefreshDate() {
    guard let lastRefreshDate = UserDefaults.standard.object(forKey: Constants.Keys.UserDefaults.kWeatherDataLastRefreshDateKey) as? Date else {
      refreshDateLabel.isHidden = true
      return
    }
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
    let dateString = dateFormatter.string(from: lastRefreshDate)
    let title = R.string.localizable.last_refresh_at(dateString)
    refreshDateLabel.text = title
    refreshDateLabel.isHidden = false
  }
  
  private func configureButtons() {
    reloadButton.isHidden = WeatherNetworkingService.shared.reachabilityStatus != .connected
    if !reloadButton.isHidden {
      reloadButton.setTitle(R.string.localizable.reload().uppercased(), for: .normal)
      reloadButton.setTitleColor(Constants.Theme.Interactables.standardButton, for: .normal)
      reloadButton.layer.cornerRadius = 5.0
      reloadButton.layer.borderColor = Constants.Theme.Interactables.standardButton.cgColor
      reloadButton.layer.borderWidth = 1.0
    }
    if WeatherDataManager.shared.hasDisplayableData {
      navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.swap(), style: .plain, target: self, action: #selector(WeatherListViewController.listTypeBarButtonTapped(_:)))
    } else {
      navigationItem.leftBarButtonItem = nil
    }
  }
  
  @objc private func updateWeatherData() {
    refreshControl.beginRefreshing()
    WeatherDataManager.shared.update(withCompletionHandler: { _ in
      DispatchQueue.main.async {
        self.refreshControl.endRefreshing()
        self.configureButtons()
        self.tableView.reloadData()
      }
    })
  }
  
  @objc private func reloadTableView(_ notification: Notification) {
    tableView.reloadData()
  }
  
  // MARK: - IBActions
  
  @objc private func listTypeBarButtonTapped(_ sender: UIBarButtonItem) {
    triggerListTypeAlert()
  }
  
  @IBAction func didTapReloadButton(_ sender: UIButton) {
    updateWeatherData()
  }
  
  @IBAction func openWeatherMapButtonPressed(_ sender: UIButton) {
    presentSafariViewController(for: Constants.Urls.kOpenWeatherMapUrl)
  }
  
  // MARK: - Helpers
  
  private func triggerListTypeAlert() {
    let alert = Factory.AlertController.make(fromType:
      .weatherListType(currentListType: listType, completionHandler: { [weak self] selectedListType in
        self?.listType = selectedListType
        DispatchQueue.main.async {
          self?.tableView.reloadData()
        }
      })
    )
    present(alert, animated: true, completion: nil)
  }
}

extension WeatherListViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    UITableView.automaticDimension
  }
  
  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    CGFloat(100)
  }
}

extension WeatherListViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    nil
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let weatherCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.weatherDataCell.identifier , for: indexPath) as! WeatherDataCell
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
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    let selectedCell = tableView.cellForRow(at: indexPath) as? WeatherDataCell
    stepper?.requestRouting(toStep:
      WeatherListStep.weatherDetails(identifier: selectedCell?.weatherDataIdentifier)
    )
  }
}
