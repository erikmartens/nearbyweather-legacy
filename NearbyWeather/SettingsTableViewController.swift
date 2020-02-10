//
//  SettingsTableViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.12.16.
//  Copyright © 2016 Erik Maximilian Martens. All rights reserved.
//

import UIKit

final class SettingsTableViewController: UITableViewController {
  
  // MARK: - Routing
  
  weak var stepper: SettingsStepper?
  
  // MARK: - ViewController LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.register(UINib(nibName: R.nib.dualLabelCell.name, bundle: R.nib.dualLabelCell.bundle),
                       forCellReuseIdentifier: R.reuseIdentifier.dualLabelCell.identifier)
    
    tableView.register(UINib(nibName: R.nib.singleLabelCell.name, bundle: R.nib.singleLabelCell.bundle),
                       forCellReuseIdentifier: R.reuseIdentifier.singleLabelCell.identifier)
    
    tableView.register(UINib(nibName: R.nib.toggleCell.name, bundle: R.nib.toggleCell.bundle),
                       forCellReuseIdentifier: R.reuseIdentifier.toggleCell.identifier)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.navigationBar.styleStandard()
    
    tableView.reloadData()
  }
  
  // MARK: - TableViewDelegate
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    switch indexPath.section {
    case 0:
      stepper?.requestRouting(toStep: .about)
    case 1:
      break
    case 2:
      if indexPath.row == 0 {
        stepper?.requestRouting(toStep: .apiKeyEdit)
        return
      }
      navigationController?.presentSafariViewController(for: Constants.Urls.kOpenWeatherMapInstructionsUrl)
    case 3:
      if indexPath.row == 0 {
        stepper?.requestRouting(toStep: .manageLocations)
      } else if indexPath.row == 1 {
        stepper?.requestRouting(toStep: .addLocation)
      }
    case 4:
      if indexPath.row == 1 {
        showOptionsAlert(withType: .preferredBookmark)
      }
    case 5:
      if indexPath.row == 0 {
        showOptionsAlert(withType: .preferredAmountOfResults)
      }
      if indexPath.row == 1 {
        showOptionsAlert(withType: .preferredSortingOrientation)
      }
      if indexPath.row == 2 {
        showOptionsAlert(withType: .preferredTemperatureUnit)
      } else {
        showOptionsAlert(withType: .preferredDistanceSpeedUnit)
      }
    default:
      break
    }
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0:
      return R.string.localizable.general()
    case 1:
      return nil
    case 2:
      return R.string.localizable.openWeatherMap_api()
    case 3:
      return R.string.localizable.bookmarks()
    case 4:
      return nil
    case 5:
      return R.string.localizable.preferences()
    default:
      return nil
    }
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 6
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return 1
    case 1:
      return 1
    case 2:
      return 2
    case 3:
      return 2
    case 4:
      return 2
    case 5:
      return 4
    default:
      return 0
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.section {
    case 0:
      let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dualLabelCell.identifier, for: indexPath) as! DualLabelCell
      cell.contentLabel.text = R.string.localizable.about()
      cell.accessoryType = .disclosureIndicator
      return cell
    case 1:
      let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.toggleCell.identifier, for: indexPath) as! ToggleCell
      cell.contentLabel.text = R.string.localizable.refresh_on_app_start()
      cell.toggle.isOn = UserDefaults.standard.bool(forKey: Constants.Keys.UserDefaults.kRefreshOnAppStartKey)
      cell.toggleSwitchHandler = { sender in
        UserDefaults.standard.set(sender.isOn, forKey: Constants.Keys.UserDefaults.kRefreshOnAppStartKey)
      }
      return cell
    case 2:
      if indexPath.row == 0 {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dualLabelCell.identifier, for: indexPath) as! DualLabelCell
        cell.contentLabel.text = R.string.localizable.apiKey()
        cell.selectionLabel.text = UserDefaults.standard.value(forKey: Constants.Keys.UserDefaults.kNearbyWeatherApiKeyKey) as? String
        cell.accessoryType = .disclosureIndicator
        return cell
      }
      let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.singleLabelCell.identifier, for: indexPath) as! SingleLabelCell
      cell.contentLabel.text = R.string.localizable.get_started_with_openweathermap()
      cell.accessoryType = .disclosureIndicator
      return cell
    case 3:
      if indexPath.row == 0 {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dualLabelCell.identifier, for: indexPath) as! DualLabelCell
        cell.contentLabel.text = R.string.localizable.manage_locations()
        
        let entriesCount = WeatherDataManager.shared.bookmarkedLocations.count
        let cellLabelTitle: String
        switch entriesCount {
        case 0:
          cellLabelTitle = R.string.localizable.empty_bookmarks()
          cell.accessoryType = .none
          cell.selectionStyle = .none
        case 1:
          cellLabelTitle = WeatherDataManager.shared.bookmarkedLocations[indexPath.row].name
          cell.accessoryType = .disclosureIndicator
          cell.selectionStyle = .default
        default:
          cellLabelTitle = "\(entriesCount)"
          cell.accessoryType = .disclosureIndicator
          cell.selectionStyle = .default
        }
        cell.selectionLabel.text = cellLabelTitle
        return cell
      }
      let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.singleLabelCell.identifier, for: indexPath) as! SingleLabelCell
      cell.contentLabel.text = R.string.localizable.add_location()
      cell.accessoryType = .disclosureIndicator
      return cell
    case 4:
      if indexPath.row == 0 {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.toggleCell.identifier, for: indexPath) as! ToggleCell
        cell.contentLabel.text = R.string.localizable.show_temp_on_icon()
        BadgeService.shared.isAppIconBadgeNotificationEnabled { enabled in
          cell.toggle.isOn = enabled
        }
        cell.toggleSwitchHandler = { [unowned self] sender in
          guard sender.isOn else {
            BadgeService.shared.setTemperatureOnAppIconEnabled(false)
            return
          }
          
          PermissionsService.shared.requestNotificationPermissions { [weak self] approved in
            guard approved else {
              sender.setOn(false, animated: true)
              self?.showNotificationsSettingsAlert()
              return
            }
            BadgeService.shared.setTemperatureOnAppIconEnabled(true)
          }
        }
        return cell
      }
      let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dualLabelCell.identifier, for: indexPath) as! DualLabelCell
      cell.contentLabel.text = R.string.localizable.preferred_bookmark()
      cell.selectionLabel.text = nil
      guard let preferredBookmarkId = PreferencesManager.shared.preferredBookmark.value,
        WeatherDataManager.shared.bookmarkedLocations.first(where: { $0.identifier == preferredBookmarkId }) != nil else {
          PreferencesManager.shared.preferredBookmark = PreferredBookmark(value: nil)
          return cell
      }
      cell.selectionLabel.text = PreferencesManager.shared.preferredBookmark.stringValue
      return cell
    case 5:
      if indexPath.row == 0 {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dualLabelCell.identifier, for: indexPath) as! DualLabelCell
        cell.contentLabel.text = R.string.localizable.amount_of_results()
        cell.selectionLabel.text = PreferencesManager.shared.amountOfResults.stringValue
        return cell
      }
      if indexPath.row == 1 {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dualLabelCell.identifier, for: indexPath) as! DualLabelCell
        cell.contentLabel.text = R.string.localizable.sorting_orientation()
        cell.selectionLabel.text = PreferencesManager.shared.sortingOrientation.stringValue
        return cell
      }
      if indexPath.row == 2 {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dualLabelCell.identifier, for: indexPath) as! DualLabelCell
        cell.contentLabel.text = R.string.localizable.temperature_unit()
        cell.selectionLabel.text = PreferencesManager.shared.temperatureUnit.stringValue
        return cell
      }
      let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dualLabelCell.identifier, for: indexPath) as! DualLabelCell
      cell.contentLabel.text = R.string.localizable.distanceSpeed_unit()
      cell.selectionLabel.text = PreferencesManager.shared.distanceSpeedUnit.stringValue
      return cell
    default:
      return UITableViewCell()
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  // MARK: - Private Helpers
  
  private enum OptionsAlertType {
    case preferredBookmark
    case preferredAmountOfResults
    case preferredSortingOrientation
    case preferredTemperatureUnit
    case preferredDistanceSpeedUnit
  }
  
  private func showOptionsAlert(withType type: OptionsAlertType) {
    let completionHandler: (Bool) -> Void = { [weak self] optionChanged in
      guard optionChanged else { return }
      DispatchQueue.main.async {
        self?.tableView.reloadData()
      }
    }
    
    var alert: UIAlertController
    
    switch type {
    case .preferredBookmark:
      var options = [PreferredBookmark(value: .none)]
      options.append(contentsOf:
        WeatherDataManager.shared.bookmarkedLocations.map { $0.identifier }.map(PreferredBookmark.init)
      )
      alert = Factory.AlertController.make(fromType:
        .preferredBookmarkOptions(options: options,
                                  completionHandler: completionHandler)
      )
    case .preferredAmountOfResults:
      alert = Factory.AlertController.make(fromType:
        .preferredAmountOfResultsOptions(options: AmountOfResults.availableOptions,
                                         completionHandler: completionHandler)
      )
    case .preferredSortingOrientation:
      alert = Factory.AlertController.make(fromType:
        .preferredSortingOrientationOptions(options: SortingOrientation.availableOptions,
                                            completionHandler: completionHandler)
      )
    case .preferredTemperatureUnit:
      alert = Factory.AlertController.make(fromType:
        .preferredTemperatureUnitOptions(options: TemperatureUnit.availableOptions,
                                         completionHandler: completionHandler)
      )
    case .preferredDistanceSpeedUnit:
      alert = Factory.AlertController.make(fromType:
        .preferredSpeedUnitOptions(options: DistanceSpeedUnit.availableOptions,
                                   completionHandler: completionHandler)
      )
    }
    present(alert, animated: true, completion: nil)
  }
  
  private func showNotificationsSettingsAlert() {
    let alert = Factory.AlertController.make(fromType: .pushNotificationsDisabled)
    present(alert, animated: true, completion: nil)
  }
}
