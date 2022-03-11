//
//  AboutAppViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa
import RxFlow
import MessageUI

// MARK: - Dependencies

extension AboutAppViewModel {
  struct Dependencies {
    let weatherStationService: WeatherStationBookmarkReading & WeatherStationBookmarkSetting
    let preferencesService: SettingsPreferencesSetting & SettingsPreferencesReading
  }
}

// MARK: - Class Definition

final class AboutAppViewModel: NSObject, Stepper, BaseViewModel {
  
  // MARK: - Routing
  
  let steps = PublishRelay<Step>()
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  
  private lazy var thirdPartyLibraries: [ThirdPartyLibraryDTO]? = {
    try? JsonPersistencyWorker().retrieveJsonFromFile(
      with: R.file.thirdPartyLibrariesJson.name,
      andDecodeAsType: ThirdPartyLibrariesWrapperDTO.self,
      fromStorageLocation: .bundle
      )
      .elements
      .sorted { $0.name.lowercased() < $1.name.lowercased() }
  }()
  
  private lazy var owner: [DevelopmentContributorDTO]? = {
    try? JsonPersistencyWorker().retrieveJsonFromFile(
      with: R.file.projectOwnerJson.name,
      andDecodeAsType: DevelopmentContributorArrayWrapper.self,
      fromStorageLocation: .bundle
      )
      .elements
      .sorted { $0.lastName.lowercased() < $1.lastName.lowercased() }
  }()
  
  private lazy var contributors: [DevelopmentContributorDTO]? = {
    try? JsonPersistencyWorker().retrieveJsonFromFile(
      with: R.file.projectContributorsJson.name,
      andDecodeAsType: DevelopmentContributorArrayWrapper.self,
      fromStorageLocation: .bundle
      )
      .elements
      .sorted { $0.lastName.lowercased() < $1.lastName.lowercased() }
  }()
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  var tableDelegate: AboutAppTableViewDelegate? // swiftlint:disable:this weak_delegate
  let tableDataSource: AboutAppTableViewDataSource
  
  // MARK: - Events
  
  let onDidChangeAllowTempOnAppIconOptionSubject = PublishSubject<Bool>()
  let onDidChangeRefreshOnAppStartOptionSubject = PublishSubject<Bool>()
  
  // MARK: - Drivers
  
  // MARK: - Observables
  
  // MARK: - Initialization
  
  required init(dependencies: Dependencies) {
    self.dependencies = dependencies
    tableDataSource = AboutAppTableViewDataSource()
    super.init()
    
    tableDelegate = AboutAppTableViewDelegate(cellSelectionDelegate: self)
  }
  
  deinit {
    printDebugMessage(
      domain: String(describing: self),
      message: "was deinitialized",
      type: .info
    )
  }
  
  // MARK: - Functions
  
  func observeEvents() {
    observeDataSource()
    observeUserTapEvents()
  }
}

// MARK: - Observations

extension AboutAppViewModel {

  func observeDataSource() {
    // App Version Section
    let appVersionSectionItems: [BaseCellViewModelProtocol] = [
      SettingsAppVersionCellViewModel(dependencies: SettingsAppVersionCellViewModel.Dependencies(
        appIconImageObseravble: Observable.just(Bundle.main.appIcon),
        appNameTitle: R.string.localizable.app_name().append(contentsOf: R.string.localizable.app_name_subtitle(), delimiter: .custom(string: " - ")),
        appVersionTitle: Constants.Values.AppVersion.kVersionBuildString
      ))
    ]
    
    let appVersionSectionObservable = Observable.just(AboutAppVersionItemsSection(sectionItems: appVersionSectionItems))
    
    // Resources Items Section Main
    let resourcesMainSectionItems: [BaseCellViewModelProtocol] = [
      SettingsSingleLabelCellViewModel(dependencies: SettingsSingleLabelCellViewModel.Dependencies(
        labelText: R.string.localizable.rate_version(),
        selectable: true,
        disclosable: true
      )),
      SettingsSingleLabelDualButtonCellViewModel(dependencies: SettingsSingleLabelDualButtonCellViewModel.Dependencies(
        contentLabelText: R.string.localizable.report_issue(),
        lhsButtonTitleText: R.string.localizable.viaGitHub(),
        rhsButtonTitleText: R.string.localizable.viaEmail()
      ))
    ]
    
    let resourcesMainSectionObservable = Observable.just(AboutAppResourcesItemsMainSection(sectionItems: resourcesMainSectionItems))
    
    // Resources Items Section Sub 1
    let resourcesSubSection1Items: [BaseCellViewModelProtocol] = [
      SettingsSingleLabelCellViewModel(dependencies: SettingsSingleLabelCellViewModel.Dependencies(
        labelText: R.string.localizable.privacy_policy(),
        selectable: true,
        disclosable: true
      )),
      SettingsSingleLabelCellViewModel(dependencies: SettingsSingleLabelCellViewModel.Dependencies(
        labelText: R.string.localizable.terms_of_use(),
        selectable: true,
        disclosable: true
      ))
    ]
    
    let resourcesSubSection1Observable = Observable.just(AboutAppResourcesItemsSubSection1(sectionItems: resourcesSubSection1Items))
    
    // Contributing Items Section
    let contributingSectionItems: [BaseCellViewModelProtocol] = [
      SettingsSingleLabelCellViewModel(dependencies: SettingsSingleLabelCellViewModel.Dependencies(
        labelText: R.string.localizable.how_to_contribute(),
        selectable: true,
        disclosable: true
      )),
      SettingsSingleLabelCellViewModel(dependencies: SettingsSingleLabelCellViewModel.Dependencies(
        labelText: R.string.localizable.source_code_via_github(),
        selectable: true,
        disclosable: true
      ))
    ]
    
    let contributingSectionObservable = Observable.just(AboutAppContributingItemsSection(sectionItems: contributingSectionItems))
    
    // Contributors Items Section Main
    let contributorsMainSectionItems: [BaseCellViewModelProtocol] = owner?.compactMap { contributor -> BaseCellViewModelProtocol in
      SettingsDualLabelSubtitleCellViewModel(dependencies: SettingsDualLabelSubtitleCellViewModel.Dependencies(
        contentLabelText: contributor.firstName.append(contentsOf: contributor.lastName, delimiter: .space),
        subtitleLabelText: contributor.localizedContributionDescription ?? "",
        selectable: true,
        disclosable: true
      ))
    } ?? []
    
    let contributorsMainSectionObservable = Observable.just(AboutAppContributorsItemsSubSection1(sectionItems: contributorsMainSectionItems))
    
    // Contributors Items Section Sub 1
    let contributorsSubSection1Items: [BaseCellViewModelProtocol] = contributors?.compactMap { contributor -> BaseCellViewModelProtocol in
      SettingsDualLabelSubtitleCellViewModel(dependencies: SettingsDualLabelSubtitleCellViewModel.Dependencies(
        contentLabelText: contributor.firstName.append(contentsOf: contributor.lastName, delimiter: .space),
        subtitleLabelText: contributor.localizedContributionDescription ?? "",
        selectable: true,
        disclosable: true
      ))
    } ?? []
    
    let contributorsSubSection1Observable = Observable.just(AboutAppContributorsItemsSubSection1(sectionItems: contributorsSubSection1Items))
    
    // Libraries Items Section
    let librariesSectionItems: [BaseCellViewModelProtocol] = thirdPartyLibraries?.compactMap { lib -> BaseCellViewModelProtocol in
      SettingsSingleLabelCellViewModel(dependencies: SettingsSingleLabelCellViewModel.Dependencies(
        labelText: lib.name,
        selectable: true,
        disclosable: true
      ))
    } ?? []
    
    let librariesSectionObservable = Observable.just(AboutAppLibrariesItemsSection(sectionItems: librariesSectionItems))
    
    Observable
      .combineLatest(
        appVersionSectionObservable,
        resourcesMainSectionObservable,
        resourcesSubSection1Observable,
        contributingSectionObservable,
        contributorsMainSectionObservable,
        contributorsSubSection1Observable,
        librariesSectionObservable,
        resultSelector: { [$0, $1, $2, $3, $4, $5, $6] }
      )
      .bind { [weak tableDataSource] in tableDataSource?.sectionDataSources.accept($0) }
      .disposed(by: disposeBag)
  }
  
  func observeUserTapEvents() {
    // nothing to do
  }
}

// MARK: - Delegate Extensions

extension AboutAppViewModel: BaseTableViewSelectionDelegate {
  
  func didSelectRow(at indexPath: IndexPath) {
    _ = Observable
      .just(indexPath)
      .map(mapIndexPathToRoutingIntent)
      .filterNil()
      .take(1)
      .asSingle()
      .subscribe(onSuccess: steps.accept)
  }
}

// MARK: - Helpers

private extension AboutAppViewModel {
  
  func mapIndexPathToRoutingIntent(_ indexPath: IndexPath) -> AboutAppStep? { // swiftlint:disable:this cyclomatic_complexity
    switch indexPath.section {
      // App Version Section
    case 0:
      return nil
      // Resources Items Section Main
    case 1:
      switch indexPath.row {
      case 0:
        return AboutAppStep.externalApp(url: Constants.Urls.kAppStoreRatingDeepLinkUrl)
      default:
        return nil
      }
    // Resources Section Sub 1
    case 2:
      switch indexPath.row {
      case 0:
        return AboutAppStep.safariViewController(url: Constants.Urls.kPrivacyPolicyUrl)
      case 1:
        return AboutAppStep.safariViewController(url: Constants.Urls.kTermsOfUseUrl)
      default:
        return nil
      }
    // Contributing Section
    case 3:
      switch indexPath.row {
      case 0:
        return AboutAppStep.safariViewController(url: Constants.Urls.kGitHubProjectContributionGuidelinesUrl)
      case 1:
        return AboutAppStep.safariViewController(url: Constants.Urls.kGitHubProjectMainPageUrl)
      default:
        return nil
      }
    // Contributors Section Main
    case 4:
      switch indexPath.row {
      case 0:
        guard let urlString = owner?.first?.urlString, let url = URL(string: urlString) else {
          return nil
        }
        return AboutAppStep.safariViewController(url: url)
      default:
        return nil
      }
    // Contributors Section Sub 1
    case 5:
      guard let urlString = contributors?[safe: indexPath.row]?.urlString, let url = URL(string: urlString) else {
        return nil
      }
      return AboutAppStep.safariViewController(url: url)
    //  Libraries Section
    case 6:
      guard let urlString = thirdPartyLibraries?[safe: indexPath.row]?.urlString, let url = URL(string: urlString) else {
        return nil
      }
      return AboutAppStep.safariViewController(url: url)
    default:
      return nil
    }
  }
}

// MARK: - Helper Extensions

private extension AboutAppViewController {
  
  func sendMail(to recipients: [String], withSubject subject: String, withMessage message: String) {
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

extension AboutAppViewController: MFMailComposeViewControllerDelegate {
  
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    controller.dismiss(animated: true, completion: nil)
  }
}
