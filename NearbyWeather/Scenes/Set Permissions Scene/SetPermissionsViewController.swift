//
//  SetPermissionsViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 15.04.17.
//  Copyright © 2017 Erik Maximilian Martens. All rights reserved.
//

import UIKit

final class SetPermissionsViewController: UIViewController {
  
  // MARK: - Routing
  
  weak var stepper: WelcomeStepper?
  
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
    configure()
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(Self.launchApp),
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
    askPermissionsButton.setTitleColor(.white, for: UIControl.State())
    askPermissionsButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
    askPermissionsButton.layer.cornerRadius = askPermissionsButton.bounds.height/2
    askPermissionsButton.layer.backgroundColor = Constants.Theme.Color.BrandColors.standardDay.cgColor
  }
  
  fileprivate func startAnimationTimer() {
    timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: (#selector(Self.animatePulse)), userInfo: nil, repeats: false)
  }
  
  @objc private func animatePulse() {
    warningImageView.layer.removeAllAnimations()
    warningImageView.animatePulse(withAnimationDelegate: self)
  }
  
  @objc func launchApp() {
    stepper?.requestRouting(toStep: .launchApp)
  }
  
  // MARK: - Button Interaction
  
  @IBAction func didTapAskPermissionsButton(_ sender: UIButton) {
    guard UserLocationService.shared.authorizationStatus != .notDetermined else {
      UserLocationService.shared.requestWhenInUseAuthorization()
      return
    }
    launchApp()
  }
}

extension SetPermissionsViewController: CAAnimationDelegate {
  
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    startAnimationTimer()
  }
}
