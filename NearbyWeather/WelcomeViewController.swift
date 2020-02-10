//
//  WelcomeScreenViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 15.04.17.
//  Copyright © 2017 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import SafariServices
import TextFieldCounter

final class WelcomeViewController: UIViewController {
  
  // MARK: - Properties
  
  private var timer: Timer?
  
  // MARK: - Outlets
  
  @IBOutlet weak var bubbleView: UIView!
  @IBOutlet weak var warningImageView: UIImageView!
  
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var inputTextField: TextFieldCounter!
  @IBOutlet weak var saveButton: UIButton!
  @IBOutlet weak var getInstructionsButtons: UIButton!
  
  // MARK: - Override Functions
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = R.string.localizable.welcome()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    configure()
    checkValidTextFieldInput()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    inputTextField.becomeFirstResponder()
    animatePulse()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    warningImageView.layer.removeAllAnimations()
    timer?.invalidate()
  }
  
  // MARK: - Helper Functions
  
  func configure() {
    navigationController?.navigationBar.styleStandard()
    
    bubbleView.layer.cornerRadius = 10
    bubbleView.backgroundColor = .black
    
    descriptionLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
    descriptionLabel.textColor = .white
    descriptionLabel.text! = R.string.localizable.welcome_api_key_description()
    
    inputTextField.counterColor = inputTextField.textColor ?? .black
    inputTextField.limitColor = Constants.Theme.Interactables.standardTint
    inputTextField.textColor = .lightGray
    inputTextField.tintColor = .lightGray
    
    saveButton.setTitle(R.string.localizable.save().uppercased(), for: .normal)
    saveButton.setTitleColor(Constants.Theme.Interactables.standardButton, for: .normal)
    saveButton.setTitleColor(Constants.Theme.Interactables.standardButton, for: .highlighted)
    saveButton.setTitleColor(.lightGray, for: .disabled)
    saveButton.layer.cornerRadius = 5.0
    saveButton.layer.borderColor = UIColor.lightGray.cgColor
    saveButton.layer.borderWidth = 1.0
    
    getInstructionsButtons.setTitle(R.string.localizable.get_api_key_description().uppercased(), for: .normal)
    getInstructionsButtons.setTitleColor(Constants.Theme.Interactables.standardButton, for: .normal)
    getInstructionsButtons.setTitleColor(Constants.Theme.Interactables.standardButton, for: .highlighted)
  }
  
  fileprivate func startAnimationTimer() {
    timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: (#selector(WelcomeViewController.animatePulse)), userInfo: nil, repeats: false)
  }
  
  @objc private func animatePulse() {
    warningImageView.layer.removeAllAnimations()
    warningImageView.animatePulse(withAnimationDelegate: self)
  }
  
  // MARK: - TextField Interaction
  
  @IBAction func inputTextFieldEditingChanged(_ sender: TextFieldCounter) {
    checkValidTextFieldInput()
    if saveButton.isEnabled {
      saveButton.layer.borderColor = Constants.Theme.Interactables.standardTint.cgColor
      return
    }
    saveButton.layer.borderColor = UIColor.lightGray.cgColor
  }
  
  private func checkValidTextFieldInput() {
    guard let text = inputTextField.text,
      text.count == 32 else {
        saveButton.isEnabled = false
        inputTextField.textColor = .lightGray
        return
    }
    saveButton.isEnabled = true
    inputTextField.textColor = Constants.Theme.Interactables.standardTint
  }
  
  // MARK: - Button Interaction
  
  @IBAction func didTapSaveButton(_ sender: UIButton) {
    inputTextField.resignFirstResponder()
    UserDefaults.standard.set(inputTextField.text, forKey: Constants.Keys.UserDefaults.kNearbyWeatherApiKeyKey)
    
    // TODO: via stepper
    let destinationViewController = R.storyboard.setPermissions.setPermissionsVC()!
    navigationController?.pushViewController(destinationViewController, animated: true)
  }
  
  @IBAction func didTapGetInstructionsButton(_ sender: UIButton) {
    presentSafariViewController(for: Constants.Urls.kOpenWeatherMapInstructionsUrl)
  }
}

extension WelcomeViewController: CAAnimationDelegate {
  
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    startAnimationTimer()
  }
}
