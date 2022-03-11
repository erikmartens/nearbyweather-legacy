//
//  AboutAppFlow.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxFlow
import Swinject
import MessageUI

// MARK: - Dependencies

extension AboutAppFlow {
  struct Dependencies {
    let rootViewController: UINavigationController
    let dependencyContainer: Container
  }
}

// MARK: - Class Definition

final class AboutAppFlow: Flow {
  
  // MARK: - Assets
  
  var root: Presentable {
    rootViewController
  }
  
  var rootViewController: UINavigationController {
    dependencies.rootViewController
  }
  
  // MARK: - Properties
  
  private let mailComposeViewControllerDelegateHelper = MailComposeViewControllerDelegateHelper()
  
  // MARK: - Dependencies
  
  private let dependencies: Dependencies
  
  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }
  
  deinit {
    printDebugMessage(
      domain: String(describing: self),
      message: "was deinitialized",
      type: .info
    )
  }
  
  // MARK: - Functions
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AboutAppStep else {
      return .none
    }
    switch step {
    case .aboutApp:
      return summonAboutAppViewController()
    case let .sendEmail(recipients, subject, message):
      return summonEmailComposeSheet(recipients: recipients, subject: subject, message: message)
    case let .safariViewController(url):
      return summonSafariViewController(with: url)
    case let .externalApp(url):
      return summonExternalApp(with: url)
    case .dismiss:
      return dismissAboutAppController()
    
    }
  }
}

// MARK: - Summoning Functions

private extension AboutAppFlow {
  func summonAboutAppViewController() -> FlowContributors {
    let aboutAppViewController = AboutAppViewController(dependencies: AboutAppViewModel.Dependencies(
      weatherStationService: dependencies.dependencyContainer.resolve(WeatherStationService2.self)!,
      preferencesService: dependencies.dependencyContainer.resolve(PreferencesService2.self)!
    ))
    
    rootViewController.pushViewController(aboutAppViewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: aboutAppViewController, withNextStepper: aboutAppViewController.viewModel))
  }
  
  func summonEmailComposeSheet(recipients: [String], subject: String, message: String) -> FlowContributors {
    guard MFMailComposeViewController.canSendMail() else {
      return .none // TODO: tell user needs to set up a mail account
    }
    
    let mailController = MFMailComposeViewController()
    mailController.mailComposeDelegate = mailComposeViewControllerDelegateHelper
    
    mailController.setToRecipients(recipients)
    mailController.setSubject(subject)
    mailController.setMessageBody(message, isHTML: false)
    
    rootViewController.present(mailController, animated: true, completion: nil)
    return .none
  }
  
  func summonSafariViewController(with url: URL) -> FlowContributors {
    rootViewController.presentSafariViewController(for: url)
    return .none
  }
  
  func summonExternalApp(with url: URL) -> FlowContributors {
    UIApplication.shared.open(url, completionHandler: nil)
    return .none
  }
  
  func dismissAboutAppController() -> FlowContributors {
    .end(forwardToParentFlowWithStep: SettingsStep.pop)
  }
}

// MARK: - Helper Extensions

private class MailComposeViewControllerDelegateHelper: NSObject {}

extension MailComposeViewControllerDelegateHelper: MFMailComposeViewControllerDelegate {
  
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    controller.dismiss(animated: true, completion: nil)
  }
}
