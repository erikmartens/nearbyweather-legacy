//
//  SetPermissionsViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 15.04.17.
//  Copyright © 2017 Erik Maximilian Martens. All rights reserved.
//

import UIKit

final class SetPermissionsViewController: UIViewController {
  
  // MARK: - Properties
  
  private var timer: Timer?
  
  // MARK: - Outlets
  
  @IBOutlet weak var bubbleView: UIView!
  @IBOutlet weak var warningImageView: UIImageView!
  
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var askPermissionsButton: UIButton!
  
  // MARK: - Override Functions
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.setHidesBackButton(true, animated: false)
    navigationItem.title = R.string.localizable.location_access()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    configure()
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(SetPermissionsViewController.launchApp),
      name: Notification.Name(rawValue: Constants.Keys.NotificationCenter.kLocationAuthorizationUpdated),
      object: nil
    )
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    animatePulse()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    warningImageView.layer.removeAllAnimations()
    timer?.invalidate()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Helper Functions
  
  func configure() {
    navigationController?.navigationBar.styleStandard()
    
    bubbleView.layer.cornerRadius = 10
    bubbleView.backgroundColor = .black
    
    descriptionLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
    descriptionLabel.textColor = .white
    descriptionLabel.text! = R.string.localizable.configure_location_permissions_description()
    
    askPermissionsButton.setTitle(R.string.localizable.configure().uppercased(), for: .normal)
    askPermissionsButton.setTitleColor(Constants.Theme.Interactables.standardButton, for: .normal)
    askPermissionsButton.setTitleColor(Constants.Theme.Interactables.standardButton, for: .highlighted)
    askPermissionsButton.layer.cornerRadius = 5.0
    askPermissionsButton.layer.borderColor = Constants.Theme.BrandColors.standardDay.cgColor
    askPermissionsButton.layer.borderWidth = 1.0
  }
  
  fileprivate func startAnimationTimer() {
    timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: (#selector(SetPermissionsViewController.animatePulse)), userInfo: nil, repeats: false)
  }
  
  @objc private func animatePulse() {
    warningImageView.layer.removeAllAnimations()
    warningImageView.animatePulse(withAnimationDelegate: self)
  }
  
  @objc func launchApp() {
    // TODO: via stepper
    NotificationCenter.default.post(
      name: Notification.Name(rawValue: WelcomeCoordinatorStep.identifier),
      object: self,
      userInfo: [Constants.Keys.AppCoordinator.kStep: WelcomeCoordinatorStep.dismiss]
    )
  }
  
  // MARK: - Button Interaction
  
  @IBAction func didTapAskPermissionsButton(_ sender: UIButton) {
    if UserLocationService.shared.authorizationStatus == .notDetermined {
      UserLocationService.shared.requestWhenInUseAuthorization()
    } else {
      launchApp()
    }
  }
}

extension SetPermissionsViewController: CAAnimationDelegate {
  
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    startAnimationTimer()
  }
}
