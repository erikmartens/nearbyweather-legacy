//
//  InfoTableViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 16.04.17.
//  Copyright © 2017 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import SafariServices
import MessageUI

final class AboutAppTableViewController: UITableViewController {
  
  private lazy var thirdPartyLibraries: [ThirdPartyLibraryDTO] = {
    return DataStorageService.retrieveJsonFromFile(with: "ThirdPartyLibraries",
                                                   andDecodeAsType: ThirdPartyLibraryArrayWrapper.self,
                                                   fromStorageLocation: .bundle)?
      .elements
      .sorted { $0.name.lowercased() < $1.name.lowercased() } ?? [ThirdPartyLibraryDTO]()
    
  }()
  
  private lazy var owner: [DevelopmentContributorDTO] = {
    return DataStorageService.retrieveJsonFromFile(with: "ProjectOwner",
                                                   andDecodeAsType: DevelopmentContributorArrayWrapper.self,
                                                   fromStorageLocation: .bundle)?
      .elements
      .sorted { $0.lastName.lowercased() < $1.lastName.lowercased() } ?? [DevelopmentContributorDTO]()
  }()
  
  private lazy var contributors: [DevelopmentContributorDTO] = {
    return DataStorageService.retrieveJsonFromFile(with: "ProjectContributors",
                                                   andDecodeAsType: DevelopmentContributorArrayWrapper.self,
                                                   fromStorageLocation: .bundle)?
      .elements
      .sorted { $0.lastName.lowercased() < $1.lastName.lowercased() } ?? [DevelopmentContributorDTO]()
  }()
  
  // MARK: - Assets
  
  @IBOutlet weak var appTitleLabel: UILabel!
  @IBOutlet weak var appVersionLabel: UILabel!
  
  // MARK: - ViewController Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = R.string.localizable.about()
    
    tableView.delegate = self
    tableView.estimatedRowHeight = 44
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    configure()
    tableView.reloadData() // in case of preferred content size change
  }
  
  // MARK: - TableView Delegate
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    if indexPath.section == 0 && indexPath.row == 0 {
      UIApplication.shared.open(Constants.Urls.kAppStoreRatingDeepLinkUrl, completionHandler: nil)
      return
    }
    
    var urlStringValue: String?
    if indexPath.section == 1 {
      urlStringValue = Constants.Urls.kPrivacyPolicyUrl.absoluteString
    }
    if indexPath.section == 2 && indexPath.row == 0 {
      urlStringValue = Constants.Urls.kGitHubProjectContributionGuidelinesUrl.absoluteString
    }
    if indexPath.section == 2 && indexPath.row == 1 {
      urlStringValue = Constants.Urls.kGitHubProjectMainPageUrl.absoluteString
    }
    if indexPath.section == 3 {
      urlStringValue = owner[indexPath.row].urlString
    }
    if indexPath.section == 4 {
      urlStringValue = contributors[indexPath.row].urlString
    }
    if indexPath.section == 5 {
      urlStringValue = thirdPartyLibraries[indexPath.row].urlString
    }
    if indexPath.section == 6 && indexPath.row == 0 {
      urlStringValue = Constants.Urls.kIconsEightUrl.absoluteString
    }
    guard let urlString = urlStringValue, let url = URL(string: urlString) else {
      return
    }
    presentSafariViewController(for: url)
  }
  
  // MARK: - TableView Data Source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 7
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return 2
    case 1:
      return 1
    case 2:
      return 2
    case 3:
      return owner.count
    case 4:
      return contributors.count
    case 5:
      return thirdPartyLibraries.count
    case 6:
      return 1
    default:
      return 0
    }
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0:
      return R.string.localizable.resources()
    case 1:
      return nil
    case 2:
      return R.string.localizable.contributors()
    case 3:
      return nil
    case 4:
      return nil
    case 5:
      return R.string.localizable.libraries()
    case 6:
      return R.string.localizable.icons()
    default:
      return nil
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let labelCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.labelCell.identifier, for: indexPath) as! LabelCell
    let subtitleCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.subtitleCell.identifier, for: indexPath) as! SubtitleCell
    let buttonCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.buttonCell.identifier, for: indexPath) as! ButtonCell
    
    [labelCell, subtitleCell].forEach {
      $0.selectionStyle = .default
      $0.accessoryType = .disclosureIndicator
    }
    buttonCell.selectionStyle = .none
    buttonCell.accessoryType = .none
    
    switch indexPath.section {
    case 0:
      if indexPath.row == 0 {
        labelCell.contentLabel.text = R.string.localizable.rate_version()
        return labelCell
      } else {
        buttonCell.configure(
          withTitle: R.string.localizable.report_issue(),
          leftButtonTitle: R.string.localizable.viaGitHub(),
          rightButtonTitle: R.string.localizable.viaEmail(),
          leftButtonHandler: { [weak self] _ in
            DispatchQueue.main.async {
              self?.presentSafariViewController(for: Constants.Urls.kGitHubProjectIssues)
            }
          },
          rightButtonHandler: { [weak self] _ in
            let mailAddress = "erikmartens.developer@gmail.com"
            let subject = "NearbyWeather - \(R.string.localizable.report_issue())"
            let message = "Hey Erik, \n"
            self?.sendMail(to: [mailAddress], withSubject: subject, withMessage: message)
          }
        )
        return buttonCell
      }
    case 1:
      labelCell.contentLabel.text = R.string.localizable.privacy_policy()
      return labelCell
    case 2:
      if indexPath.row == 0 {
        labelCell.contentLabel.text = R.string.localizable.how_to_contribute()
        return labelCell
      } else {
        labelCell.contentLabel.text = R.string.localizable.source_code_via_github()
        return labelCell
      }
    case 3:
      let contributor = owner[indexPath.row]
      subtitleCell.contentLabel.text = "\(contributor.firstName) \(contributor.lastName)"
      subtitleCell.subtitleLabel.text = contributor.localizedContributionDescription
      return subtitleCell
    case 4:
      let contributor = contributors[indexPath.row]
      subtitleCell.contentLabel.text = "\(contributor.firstName) \(contributor.lastName)"
      subtitleCell.subtitleLabel.text = contributor.localizedContributionDescription
      return subtitleCell
    case 5:
      labelCell.contentLabel.text = thirdPartyLibraries[indexPath.row].name
      return labelCell
    case 6:
      labelCell.contentLabel.text = "Icons8"
      return labelCell
    default:
      return UITableViewCell()
    }
  }
  
  // MARK: - Private Helpers
  
  private func configure() {
    navigationController?.navigationBar.styleStandard()
    configureText()
  }
  
  private func configureText() {
    appTitleLabel.text = R.string.localizable.app_title()
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "#UNDEFINED"
    let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "#UNDEFINED"
    appVersionLabel.text = "Version \(appVersion) Build #\(appBuild)"
  }
  
  private func sendMail(to recipients: [String], withSubject subject: String, withMessage message: String) {
    guard MFMailComposeViewController.canSendMail() else {
      return
    }
    
    let mailController = MFMailComposeViewController()
    mailController.mailComposeDelegate = self
    
    mailController.setToRecipients(recipients)
    mailController.setSubject(subject)
    mailController.setMessageBody(message, isHTML: false)
    
    navigationController?.present(mailController, animated: true, completion: nil)
  }
}

extension AboutAppTableViewController: MFMailComposeViewControllerDelegate {
  
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    controller.dismiss(animated: true, completion: nil)
  }
}
