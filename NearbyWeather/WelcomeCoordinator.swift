//
//  WelcomeCoordinator.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 01.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit

enum WelcomeCoordinatorStep: StepProtocol {  
  case initial
  case setPermissions
  case launchApp
}

final class WelcomeCoordinator: Coordinator {
  
  // MARK: - Required Properties
  
  private static var _rootViewController: UINavigationController = {
    let navigationController = UINavigationController()
    navigationController.navigationBar.backgroundColor = .white
    navigationController.navigationBar.barTintColor = .black
    navigationController.navigationBar.tintColor = Constants.Theme.BrandColors.standardDay
    return navigationController
  }()
  
  private static var _stepper: WelcomeStepper = {
    let initialStep = InitialStep(
      identifier: WelcomeCoordinatorStep.identifier,
      step: WelcomeCoordinatorStep.initial
    )
    return WelcomeStepper(initialStep: initialStep, type: WelcomeCoordinatorStep.self)
  }()
  
  // MARK: - Additional Properties
  
  weak var windowManager: WindowManager?

  // MARK: - Initialization
  
  init(parentCoordinator: Coordinator?, windowManager: WindowManager) {
    self.windowManager = windowManager
    
    super.init(
      rootViewController: Self._rootViewController,
      stepper: Self._stepper,
      parentCoordinator: parentCoordinator,
      type: WelcomeCoordinatorStep.self
    )
  }
  
  // MARK: - Navigation
  
  @objc override func didReceiveStep(_ notification: Notification) {
    super.didReceiveStep(notification, type: WelcomeCoordinatorStep.self)
  }
  
  override func executeRoutingStep(_ step: StepProtocol, passNextChildCoordinatorTo coordinatorReceiver: @escaping (NextCoordinator) -> Void) {
    guard let step = step as? WelcomeCoordinatorStep else { return }
    switch step {
    case .initial:
      summonWelcomeWindow(passNextChildCoordinatorTo: coordinatorReceiver)
    case .setPermissions:
      summonSetPermissions(passNextChildCoordinatorTo: coordinatorReceiver)
    case .launchApp:
      dismissWelcomeWindow(passNextChildCoordinatorTo: coordinatorReceiver)
    }
  }
}
  
  // MARK: - Navigation Helper Functions

private extension WelcomeCoordinator {
  
  private func summonWelcomeWindow(passNextChildCoordinatorTo coordinatorReceiver: (NextCoordinator) -> Void) {
   
    let welcomeViewController = R.storyboard.welcome.welcomeScreenViewController()!
    welcomeViewController.navigationItem.title = R.string.localizable.welcome()
    welcomeViewController.stepper = stepper as? WelcomeStepper
    
    let root = rootViewController as? UINavigationController
    root?.setViewControllers([welcomeViewController], animated: false)
    
    let splashScreenWindow = UIWindow(frame: UIScreen.main.bounds)
    splashScreenWindow.rootViewController = root
    splashScreenWindow.windowLevel = UIWindow.Level.alert
    splashScreenWindow.makeKeyAndVisible()
    
    windowManager?.splashScreenWindow = splashScreenWindow
    
    coordinatorReceiver(.none)
  }
  
  private func summonSetPermissions(passNextChildCoordinatorTo coordinatorReceiver: (NextCoordinator) -> Void) {
    let setPermissionsController = R.storyboard.setPermissions.setPermissionsVC()!
    setPermissionsController.navigationItem.title = R.string.localizable.location_access()
    setPermissionsController.stepper = stepper as? WelcomeStepper
    
    let root = rootViewController as? UINavigationController
    root?.pushViewController(setPermissionsController, animated: true)
  }
  
  private func dismissWelcomeWindow(passNextChildCoordinatorTo coordinatorReceiver: (NextCoordinator) -> Void) {
    UIView.animate(withDuration: 0.2,
                   animations: { [weak self] in
                    self?.windowManager?.splashScreenWindow?.alpha = 0
                    self?.windowManager?.splashScreenWindow?.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
      },
                   completion: { [weak self] _ in
                    self?.windowManager?.splashScreenWindow?.resignKey()
                    self?.windowManager?.splashScreenWindow = nil
                    self?.windowManager?.window?.makeKeyAndVisible()
    })
    
    coordinatorReceiver(.destroy(self))
  }
}
