//
//  SettingsTableViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.12.16.
//  Copyright © 2016 Erik Maximilian Martens. All rights reserved.
//

import UIKit

final class SettingsTableViewController: UITableViewController {
  
  // MARK: - ViewController LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = R.string.localizable.tab_settings()
    
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
      let destinationViewController = R.storyboard.settings.infoTableViewController()!
      navigationItem.removeTextFromBackBarButton()
      navigationController?.pushViewController(destinationViewController, animated: true)
    case 1:
      break
    case 2:
      if indexPath.row == 0 {
        let destinationViewController = R.storyboard.settings.settingsInputTVC()!
        
        navigationItem.removeTextFromBackBarButton()
        navigationController?.pushViewController(destinationViewController, animated: true)
        return
      }
      navigationController?.presentSafariViewController(for: Constants.Urls.kOpenWeatherMapInstructionsUrl)
    case 3:
      if indexPath.row == 0 {
        guard !WeatherDataManager.shared.bookmarkedLocations.isEmpty else {
          break
        }
        let destinationViewController = R.storyboard.settings.weatherLocationManagementTableViewController()!
        
        navigationItem.removeTextFromBackBarButton()
        navigationController?.pushViewController(destinationViewController, animated: true)
      } else if indexPath.row == 1 {
        let destinationViewController = R.storyboard.settings.owmCityFilterTableViewController()!
        
        navigationItem.removeTextFromBackBarButton()
        navigationController?.pushViewController(destinationViewController, animated: true)
      }
    case 4:
      if indexPath.row == 1 {
        var choices = [PreferredBookmark(value: .none)]
        let bookmarksChoices = WeatherDataManager.shared.bookmarkedLocations.map { PreferredBookmark(value: $0.identifier) }
        choices.append(contentsOf: bookmarksChoices)
        triggerOptionsAlert(forOptions: choices, title: R.string.localizable.preferred_bookmark())
      }
    case 5:
      if indexPath.row == 0 {
        triggerOptionsAlert(forOptions: amountOfResultsOptions, title: R.string.localizable.amount_of_results())
      }
      if indexPath.row == 1 {
        triggerOptionsAlert(forOptions: sortResultsOptions, title: R.string.localizable.sorting_orientation())
      }
      if indexPath.row == 2 {
        triggerOptionsAlert(forOptions: temperatureUnitOptions, title: R.string.localizable.temperature_unit())
      } else {
        triggerOptionsAlert(forOptions: distanceSpeedUnitOptions, title: R.string.localizable.distanceSpeed_unit())
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
          
          PermissionsManager.shared.requestNotificationPermissions { [weak self] approved in
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
  
  private struct SettingsAlertOption<T: PreferencesOption> { var title: String; var value: Int; var preferenceType: T.Type }
  
  private let amountOfResultsOptions = [AmountOfResults(value: .ten),
                                        AmountOfResults(value: .twenty),
                                        AmountOfResults(value: .thirty),
                                        AmountOfResults(value: .forty),
                                        AmountOfResults(value: .fifty)]
  
  private let sortResultsOptions = [SortingOrientation(value: .name),
                                    SortingOrientation(value: .temperature),
                                    SortingOrientation(value: .distance)]
  
  private let temperatureUnitOptions = [TemperatureUnit(value: .celsius),
                                        TemperatureUnit(value: .fahrenheit),
                                        TemperatureUnit(value: .kelvin)]
  
  private let distanceSpeedUnitOptions = [DistanceSpeedUnit(value: .kilometres),
                                          DistanceSpeedUnit(value: .miles)]
  
  private func triggerOptionsAlert<T: PreferencesOption>(forOptions options: [T], title: String) {
    let optionsAlert: UIAlertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
    
    let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .cancel, handler: nil)
    
    // force unwrap options below -> this should never fail, if it does the app should crash so we know
    options.forEach { option in
      var actionIsSelected = false
      switch option {
      case is PreferredBookmark:
        if PreferencesManager.shared.preferredBookmark.value == (option as! PreferredBookmark).value {
          actionIsSelected = true
        }
      case is AmountOfResults:
        if PreferencesManager.shared.amountOfResults.value == (option as! AmountOfResults).value {
          actionIsSelected = true
        }
      case is SortingOrientation:
        if (option as! SortingOrientation).value == .distance
          && !LocationService.shared.locationPermissionsGranted {
          return
        }
        if PreferencesManager.shared.sortingOrientation.value == (option as! SortingOrientation).value {
          actionIsSelected = true
        }
      case is TemperatureUnit:
        if PreferencesManager.shared.temperatureUnit.value == (option as! TemperatureUnit).value {
          actionIsSelected = true
        }
      case is DistanceSpeedUnit:
        if PreferencesManager.shared.distanceSpeedUnit.value == (option as! DistanceSpeedUnit).value {
          actionIsSelected = true
        }
      default:
        return
      }
      
      let action = UIAlertAction(title: option.stringValue, style: .default, handler: { _ in
        switch option {
        case is PreferredBookmark:
          PreferencesManager.shared.preferredBookmark = option as! PreferredBookmark
        case is AmountOfResults:
          PreferencesManager.shared.amountOfResults = option as! AmountOfResults
        case is SortingOrientation:
          PreferencesManager.shared.sortingOrientation = option as! SortingOrientation
        case is TemperatureUnit:
          PreferencesManager.shared.temperatureUnit = option as! TemperatureUnit
        case is DistanceSpeedUnit:
          PreferencesManager.shared.distanceSpeedUnit = option as! DistanceSpeedUnit
        default:
          return
        }
        self.tableView.reloadData()
      })
      if actionIsSelected {
        action.setValue(true, forKey: "checked")
      }
      optionsAlert.addAction(action)
    }
    
    optionsAlert.addAction(cancelAction)
    
    present(optionsAlert, animated: true, completion: nil)
  }
  
  private func showNotificationsSettingsAlert() {
    let alertController = UIAlertController(title: R.string.localizable.notifications_disabled(), message: R.string.localizable.enable_notifications_alert_text(), preferredStyle: .alert)
    
    let settingsAction = UIAlertAction(title: R.string.localizable.settings(), style: .default) { _ -> Void in
      guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
        UIApplication.shared.canOpenURL(settingsUrl) else {
          return
      }
      UIApplication.shared.open(settingsUrl, completionHandler: nil)
    }
    let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .cancel)
    
    alertController.addAction(settingsAction)
    alertController.addAction(cancelAction)
    present(alertController, animated: true, completion: nil)
  }
}
