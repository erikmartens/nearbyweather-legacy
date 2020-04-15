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
    DataStorageWorker.retrieveJsonFromFile(with: R.file.thirdPartyLibrariesJson.name,
                                                   andDecodeAsType: ThirdPartyLibraryArrayWrapper.self,
                                                   fromStorageLocation: .bundle)?
      .elements
      .sorted { $0.name.lowercased() < $1.name.lowercased() } ?? [ThirdPartyLibraryDTO]()
    
  }()
  
  private lazy var owner: [DevelopmentContributorDTO] = {
    DataStorageWorker.retrieveJsonFromFile(with: R.file.projectOwnerJson.name,
                                                   andDecodeAsType: DevelopmentContributorArrayWrapper.self,
                                                   fromStorageLocation: .bundle)?
      .elements
      .sorted { $0.lastName.lowercased() < $1.lastName.lowercased() } ?? [DevelopmentContributorDTO]()
  }()
  
  private lazy var contributors: [DevelopmentContributorDTO] = {
    DataStorageWorker.retrieveJsonFromFile(with: R.file.projectContributorsJson.name,
                                                   andDecodeAsType: DevelopmentContributorArrayWrapper.self,
                                                   fromStorageLocation: .bundle)?
      .elements
      .sorted { $0.lastName.lowercased() < $1.lastName.lowercased() } ?? [DevelopmentContributorDTO]()
  }()
  
  // MARK: - Routing
  
  weak var stepper: SettingsStepper?
  
  // MARK: - IBOutlets
  
  @IBOutlet weak var appTitleLabel: UILabel!
  @IBOutlet weak var appVersionLabel: UILabel!
  
  // MARK: - ViewController Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.delegate = self
    tableView.estimatedRowHeight = 44
    
    tableView.register(UINib(nibName: R.nib.singleLabelCell.name, bundle: R.nib.singleLabelCell.bundle),
                       forCellReuseIdentifier: R.reuseIdentifier.singleLabelCell.identifier)
    
    tableView.register(UINib(nibName: R.nib.subtitleCell.name, bundle: R.nib.subtitleCell.bundle),
                       forCellReuseIdentifier: R.reuseIdentifier.subtitleCell.identifier)
    
    tableView.register(ButtonCell.self, forCellReuseIdentifier: ButtonCell.reuseIdentifier)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    configure()
    tableView.reloadData() // in case of preferred content size change
  }
  
  // MARK: - TableView Delegate
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    UITableView.automaticDimension
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    if indexPath.section == 0 && indexPath.row == 0 {
      UIApplication.shared.open(Constants.Urls.kAppStoreRatingDeepLinkUrl, completionHandler: nil)
      return
    }
    
    var urlStringValue: String?
    if indexPath.section == 1 && indexPath.row == 0 {
      urlStringValue = Constants.Urls.kPrivacyPolicyUrl.absoluteString
    }
    if indexPath.section == 1 && indexPath.row == 1 {
      urlStringValue = Constants.Urls.kTermsOfUseUrl.absoluteString
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
    guard let urlString = urlStringValue, let url = URL(string: urlString) else {
      return
    }
    presentSafariViewController(for: url)
  }
  
  // MARK: - TableView Data Source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    6
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return 2
    case 1:
      return 2
    case 2:
      return 2
    case 3:
      return owner.count
    case 4:
      return contributors.count
    case 5:
      return thirdPartyLibraries.count
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
      return R.string.localizable.contributing()
    case 3:
      return R.string.localizable.contributors()
    case 4:
      return nil
    case 5:
      return R.string.localizable.libraries()
    default:
      return nil
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let singleLabelCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.singleLabelCell.identifier, for: indexPath) as! SingleLabelCell
    let subtitleCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.subtitleCell.identifier, for: indexPath) as! SubtitleCell
    let buttonCell = tableView.dequeueReusableCell(withIdentifier: ButtonCell.reuseIdentifier, for: indexPath) as! ButtonCell
    
    [singleLabelCell, subtitleCell].forEach {
      $0.selectionStyle = .default
      $0.accessoryType = .disclosureIndicator
    }
    buttonCell.selectionStyle = .none
    buttonCell.accessoryType = .none
    
    switch indexPath.section {
    case 0:
      if indexPath.row == 0 {
        singleLabelCell.contentLabel.text = R.string.localizable.rate_version()
        return singleLabelCell
      }
      buttonCell.configure(
        withTitle: R.string.localizable.report_issue(),
        leftButtonTitle: R.string.localizable.viaGitHub(),
        rightButtonTitle: R.string.localizable.viaEmail(),
        leftButtonHandler: { [weak self] _ in
          DispatchQueue.main.async {
            self?.presentSafariViewController(for: Constants.Urls.kGitHubProjectIssuesUrl)
          }
        },
        rightButtonHandler: { [weak self] _ in
          self?.sendMail(
            to: [Constants.EmailAdresses.mainContact],
            withSubject: R.string.localizable.app_name()
              .append(contentsOf: R.string.localizable.report_issue(), delimiter: .custom(string: " - ")),
            withMessage: R.string.localizable.email_salutation()
          )
        }
      )
      return buttonCell
    case 1:
      if indexPath.row == 0 {
        singleLabelCell.contentLabel.text = R.string.localizable.privacy_policy()
        return singleLabelCell
      } else {
        singleLabelCell.contentLabel.text = R.string.localizable.terms_of_use()
        return singleLabelCell
      }
    case 2:
      if indexPath.row == 0 {
        singleLabelCell.contentLabel.text = R.string.localizable.how_to_contribute()
        return singleLabelCell
      } else {
        singleLabelCell.contentLabel.text = R.string.localizable.source_code_via_github()
        return singleLabelCell
      }
    case 3:
      let contributor = owner[indexPath.row]
      subtitleCell.contentLabel.text = contributor.firstName.append(contentsOf: contributor.lastName, delimiter: .space)
      subtitleCell.subtitleLabel.text = contributor.localizedContributionDescription
      return subtitleCell
    case 4:
      let contributor = contributors[indexPath.row]
      subtitleCell.contentLabel.text = contributor.firstName.append(contentsOf: contributor.lastName, delimiter: .space)
      subtitleCell.subtitleLabel.text = contributor.localizedContributionDescription
      return subtitleCell
    case 5:
      singleLabelCell.contentLabel.text = thirdPartyLibraries[indexPath.row].name
      return singleLabelCell
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
    appTitleLabel.text = R.string.localizable.app_name().append(contentsOf: R.string.localizable.app_name_subtitle(), delimiter: .custom(string: " - "))
    appVersionLabel.text = Constants.Values.AppVersion.kVersionBuildString
  }
  
  private func sendMail(to recipients: [String], withSubject subject: String, withMessage message: String) {
    guard MFMailComposeViewController.canSendMail() else {
      return // TODO: tell user needs to set up a mail account
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
