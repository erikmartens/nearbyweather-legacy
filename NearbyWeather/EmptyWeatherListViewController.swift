//
//  EmptyWeatherListViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 16.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit

final class EmptyWeatherListViewController: UIViewController {
  
  // MARK: - Routing
  
  weak var stepper: WeatherListStepper?
  
  // MARK: - IBOutlets
  
  @IBOutlet weak var emptyListImageView: UIImageView!
  @IBOutlet weak var emptyListTitleLabel: UILabel!
  @IBOutlet weak var emptyListDescriptionLabel: UILabel!
  
  @IBOutlet weak var reloadButton: UIButton!
  
  // MARK: - ViewController Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBar.isHidden = true
    
    configureWeatherDataUnavailableElements()
    configureButtons()
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(Self.reconfigureOnNetworkDidBecomeAvailable),
      name: Notification.Name(rawValue: Constants.Keys.NotificationCenter.kNetworkReachabilityChanged),
      object: nil
    )
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - IBActions
  
  @IBAction func didTapReloadButton(_ sender: UIButton) {
    WeatherDataManager.shared.update(withCompletionHandler: nil)
  }
  
  // MARK: - Functions
  
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
  
  private func configureButtons() {
    reloadButton.isHidden = WeatherNetworkingService.shared.reachabilityStatus != .connected
    
    reloadButton.setTitle(R.string.localizable.reload().uppercased(), for: .normal)
    reloadButton.setTitleColor(Constants.Theme.Interactables.standardButton, for: .normal)
    reloadButton.layer.cornerRadius = 5.0
    reloadButton.layer.borderColor = Constants.Theme.Interactables.standardButton.cgColor
    reloadButton.layer.borderWidth = 1.0
  }
}
