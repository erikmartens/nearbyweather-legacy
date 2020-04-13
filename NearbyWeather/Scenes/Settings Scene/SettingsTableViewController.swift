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
    
    tableView.register(ImagedSingleLabelCell.self, forCellReuseIdentifier: ImagedSingleLabelCell.reuseIdentifier)
    
    tableView.register(ImagedDualLabelCell.self, forCellReuseIdentifier: ImagedDualLabelCell.reuseIdentifier)
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
      if indexPath.row == 0 {
        stepper?.requestRouting(toStep: .apiKeyEdit)
        return
      }
      navigationController?.presentSafariViewController(for: Constants.Urls.kOpenWeatherMapInstructionsUrl)
    case 2:
      if indexPath.row == 0 {
        stepper?.requestRouting(toStep: .manageLocations)
      } else if indexPath.row == 1 {
        stepper?.requestRouting(toStep: .addLocation)
      }
    case 3:
      if indexPath.row == 1 {
        showOptionsAlert(withType: .preferredBookmark)
      }
    case 4:
      break
    case 5:
      if indexPath.row == 0 {
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
      return R.string.localizable.openWeatherMap_api()
    case 2:
      return R.string.localizable.bookmarks()
    case 3:
      return nil
    case 4:
      return R.string.localizable.preferences()
    case 5:
      return nil
    default:
      return nil
    }
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    6
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return 1
    case 1:
      return 2
    case 2:
      return 2
    case 3:
      return 2
    case 4:
      return 1
    case 5:
      return 2
    default:
      return 0
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.section {
    case 0:
      let cell = tableView.dequeueReusableCell(withIdentifier: ImagedSingleLabelCell.reuseIdentifier, for: indexPath) as! ImagedSingleLabelCell
      cell.configure(withTitle: R.string.localizable.about(), image: R.image.info(), imageBackgroundColor: Constants.Theme.Color.BrandColors.standardDay)
      cell.accessoryType = .disclosureIndicator
      return cell
    case 1:
      if indexPath.row == 0 {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagedDualLabelCell.reuseIdentifier, for: indexPath) as! ImagedDualLabelCell
        cell.configure(
          withTitle: R.string.localizable.apiKey(),
          description: UserDefaults.standard.value(forKey: Constants.Keys.UserDefaults.kNearbyWeatherApiKeyKey) as? String,
          image: R.image.seal(),
          imageBackgroundColor: .green
        )
        cell.accessoryType = .disclosureIndicator
        return cell
      }
      let cell = tableView.dequeueReusableCell(withIdentifier: ImagedSingleLabelCell.reuseIdentifier, for: indexPath) as! ImagedSingleLabelCell
      cell.configure(withTitle: R.string.localizable.get_started_with_openweathermap(), image: R.image.start(), imageBackgroundColor: .green)
      cell.accessoryType = .disclosureIndicator
      return cell
    case 2:
      if indexPath.row == 0 {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagedDualLabelCell.reuseIdentifier, for: indexPath) as! ImagedDualLabelCell
        
        let entriesCount = WeatherDataService.shared.bookmarkedLocations.count
        let description: String
        switch entriesCount {
        case 0:
          description = R.string.localizable.empty_bookmarks()
          cell.accessoryType = .none
          cell.selectionStyle = .none
        case 1:
          description = WeatherDataService.shared.bookmarkedLocations[indexPath.row].name
          cell.accessoryType = .disclosureIndicator
          cell.selectionStyle = .default
        default:
          description = String(describing: entriesCount)
          cell.accessoryType = .disclosureIndicator
          cell.selectionStyle = .default
        }
        
        cell.configure(
          withTitle: R.string.localizable.manage_locations(),
          description: description,
          image: R.image.wrench(),
          imageBackgroundColor: .red
        )
        return cell
      }
      let cell = tableView.dequeueReusableCell(withIdentifier: ImagedSingleLabelCell.reuseIdentifier, for: indexPath) as! ImagedSingleLabelCell
      cell.configure(withTitle: R.string.localizable.add_location(), image: R.image.add_bookmark(), imageBackgroundColor: .red)
      cell.accessoryType = .disclosureIndicator
      return cell
    case 3:
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
      let cell = tableView.dequeueReusableCell(withIdentifier: ImagedDualLabelCell.reuseIdentifier, for: indexPath) as! ImagedDualLabelCell
      
      // TODO: fix this
      if let preferredBookmarkId = PreferencesDataService.shared.preferredBookmark.value,
        WeatherDataService.shared.bookmarkedLocations.first(where: { $0.identifier == preferredBookmarkId }) == nil {
          PreferencesDataService.shared.preferredBookmark = PreferredBookmarkOption(value: nil)
      }
      
      cell.configure(
        withTitle: R.string.localizable.preferred_bookmark(),
        description: PreferencesDataService.shared.preferredBookmark.stringValue,
        image: R.image.preferred_bookmark(),
        imageBackgroundColor: .red
      )
      
      return cell
    case 4:
      let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.toggleCell.identifier, for: indexPath) as! ToggleCell
      cell.contentLabel.text = R.string.localizable.refresh_on_app_start()
      cell.toggle.isOn = UserDefaults.standard.bool(forKey: Constants.Keys.UserDefaults.kRefreshOnAppStartKey)
      cell.toggleSwitchHandler = { sender in
        UserDefaults.standard.set(sender.isOn, forKey: Constants.Keys.UserDefaults.kRefreshOnAppStartKey)
      }
    return cell
    case 5:
      if indexPath.row == 0 {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagedDualLabelCell.reuseIdentifier, for: indexPath) as! ImagedDualLabelCell
        cell.configure(
          withTitle: R.string.localizable.temperature_unit(),
          description: PreferencesDataService.shared.temperatureUnit.stringValue,
          image: R.image.thermometer(),
          imageBackgroundColor: .gray
        )
        return cell
      }
      let cell = tableView.dequeueReusableCell(withIdentifier: ImagedDualLabelCell.reuseIdentifier, for: indexPath) as! ImagedDualLabelCell
      cell.configure(
        withTitle: R.string.localizable.distanceSpeed_unit(),
        description: PreferencesDataService.shared.distanceSpeedUnit.stringValue,
        image: R.image.dimension(),
        imageBackgroundColor: .gray
      )
      return cell
    default:
      return UITableViewCell()
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    UITableView.automaticDimension
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
      var options = [PreferredBookmarkOption(value: .none)]
      options.append(contentsOf:
        WeatherDataService.shared.bookmarkedLocations.map { $0.identifier }.map(PreferredBookmarkOption.init)
      )
      alert = Factory.AlertController.make(fromType:
        .preferredBookmarkOptions(options: options,
                                  completionHandler: completionHandler)
      )
    case .preferredTemperatureUnit:
      alert = Factory.AlertController.make(fromType:
        .preferredTemperatureUnitOptions(options: TemperatureUnitOption.availableOptions,
                                         completionHandler: completionHandler)
      )
    case .preferredDistanceSpeedUnit:
      alert = Factory.AlertController.make(fromType:
        .preferredSpeedUnitOptions(options: DistanceVelocityUnitOption.availableOptions,
                                   completionHandler: completionHandler)
      )
    case .preferredAmountOfResults, .preferredSortingOrientation:
      return // these options cannot be configured in settings
    }
    present(alert, animated: true, completion: nil)
  }
  
  private func showNotificationsSettingsAlert() {
    let alert = Factory.AlertController.make(fromType: .pushNotificationsDisabled)
    present(alert, animated: true, completion: nil)
  }
}
