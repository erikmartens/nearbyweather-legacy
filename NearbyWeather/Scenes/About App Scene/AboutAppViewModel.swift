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
  
  let onDidPressReportIssueViaGitHubCellButtonSubject = PublishSubject<Void>()
  let onDidPressReportIssueViaEmailCellButtonSubject = PublishSubject<Void>()
  
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
    // 0: App Version Section
    let appVersionSectionItems: [BaseCellViewModelProtocol] = [
      SettingsAppVersionCellViewModel(dependencies: SettingsAppVersionCellViewModel.Dependencies(
        appIconImageObseravble: Observable.just(Bundle.main.appIcon),
        appNameTitle: R.string.localizable.app_name().append(contentsOf: R.string.localizable.app_name_subtitle(), delimiter: .custom(string: " - ")),
        appVersionTitle: Constants.Values.AppVersion.kVersionBuildString
      ))
    ]
    
    let appVersionSectionObservable = Observable.just(AboutAppVersionItemsSection(sectionItems: appVersionSectionItems))
    
    // 1: Resources Items Section Main
    let resourcesMainSectionItems: [BaseCellViewModelProtocol] = [
      SettingsSingleLabelCellViewModel(dependencies: SettingsSingleLabelCellViewModel.Dependencies(
        labelText: R.string.localizable.rate_version(),
        selectable: true,
        disclosable: true,
        routingIntent: AboutAppStep.externalApp(url: Constants.Urls.kAppStoreRatingDeepLinkUrl)
      )),
      SettingsSingleLabelDualButtonCellViewModel(dependencies: SettingsSingleLabelDualButtonCellViewModel.Dependencies(
        contentLabelText: R.string.localizable.report_issue(),
        lhsButtonTitleText: R.string.localizable.viaGitHub(),
        rhsButtonTitleText: R.string.localizable.viaEmail(),
        didTapLhsButtonSubject: onDidPressReportIssueViaGitHubCellButtonSubject,
        didTapRhsButtonSubject: onDidPressReportIssueViaEmailCellButtonSubject
      ))
    ]
    
    let resourcesMainSectionObservable = Observable.just(AboutAppResourcesItemsMainSection(sectionItems: resourcesMainSectionItems))
    
    // 2: Resources Items Section Sub 1
    let resourcesSubSection1Items: [BaseCellViewModelProtocol] = [
      SettingsSingleLabelCellViewModel(dependencies: SettingsSingleLabelCellViewModel.Dependencies(
        labelText: R.string.localizable.privacy_policy(),
        selectable: true,
        disclosable: true,
        routingIntent: AboutAppStep.safariViewController(url: Constants.Urls.kPrivacyPolicyUrl)
      )),
      SettingsSingleLabelCellViewModel(dependencies: SettingsSingleLabelCellViewModel.Dependencies(
        labelText: R.string.localizable.terms_of_use(),
        selectable: true,
        disclosable: true,
        routingIntent: AboutAppStep.safariViewController(url: Constants.Urls.kTermsOfUseUrl)
      ))
    ]
    
    let resourcesSubSection1Observable = Observable.just(AboutAppResourcesItemsSubSection1(sectionItems: resourcesSubSection1Items))
    
    // 3: Contributing Items Section
    let contributingSectionItems: [BaseCellViewModelProtocol] = [
      SettingsSingleLabelCellViewModel(dependencies: SettingsSingleLabelCellViewModel.Dependencies(
        labelText: R.string.localizable.how_to_contribute(),
        selectable: true,
        disclosable: true,
        routingIntent: AboutAppStep.safariViewController(url: Constants.Urls.kGitHubProjectContributionGuidelinesUrl)
      )),
      SettingsSingleLabelCellViewModel(dependencies: SettingsSingleLabelCellViewModel.Dependencies(
        labelText: R.string.localizable.source_code_via_github(),
        selectable: true,
        disclosable: true,
        routingIntent: AboutAppStep.safariViewController(url: Constants.Urls.kGitHubProjectMainPageUrl)
      ))
    ]
    
    let contributingSectionObservable = Observable.just(AboutAppContributingItemsSection(sectionItems: contributingSectionItems))
    
    // 4: Contributors Items Section Main
    let contributorsMainSectionItems: [BaseCellViewModelProtocol] = owner?.compactMap { contributor -> BaseCellViewModelProtocol in
      SettingsDualLabelSubtitleCellViewModel(dependencies: SettingsDualLabelSubtitleCellViewModel.Dependencies(
        contentLabelText: contributor.firstName.append(contentsOf: contributor.lastName, delimiter: .space),
        subtitleLabelText: contributor.localizedContributionDescription ?? "",
        selectable: true,
        disclosable: true,
        routingIntent: {
          guard let urlString = owner?.first?.urlString, let url = URL(string: urlString) else {
            return nil
          }
          return AboutAppStep.safariViewController(url: url)
        }()
      ))
    } ?? []
    
    let contributorsMainSectionObservable = Observable.just(AboutAppContributorsItemsSubSection1(sectionItems: contributorsMainSectionItems))
    
    // 5: Contributors Items Section Sub 1
    let contributorsSubSection1Items: [BaseCellViewModelProtocol] = contributors?.compactMap { contributor -> BaseCellViewModelProtocol in
      SettingsDualLabelSubtitleCellViewModel(dependencies: SettingsDualLabelSubtitleCellViewModel.Dependencies(
        contentLabelText: contributor.firstName.append(contentsOf: contributor.lastName, delimiter: .space),
        subtitleLabelText: contributor.localizedContributionDescription ?? "",
        selectable: true,
        disclosable: true,
        routingIntent: {
          guard let row = contributors?.firstIndex(of: contributor),
                  let urlString = contributors?[safe: row]?.urlString,
                  let url = URL(string: urlString) else {
            return nil
          }
          return AboutAppStep.safariViewController(url: url)
        }()
      ))
    } ?? []
    
    let contributorsSubSection1Observable = Observable.just(AboutAppContributorsItemsSubSection1(sectionItems: contributorsSubSection1Items))
    
    // 6: Libraries Items Section
    let librariesSectionItems: [BaseCellViewModelProtocol] = thirdPartyLibraries?.compactMap { lib -> BaseCellViewModelProtocol in
      SettingsSingleLabelCellViewModel(dependencies: SettingsSingleLabelCellViewModel.Dependencies(
        labelText: lib.name,
        selectable: true,
        disclosable: true,
        routingIntent: {
          guard let row = thirdPartyLibraries?.firstIndex(of: lib),
                let urlString = thirdPartyLibraries?[safe: row]?.urlString,
                let url = URL(string: urlString) else {
            return nil
          }
          return AboutAppStep.safariViewController(url: url)
        }()
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
    onDidPressReportIssueViaGitHubCellButtonSubject
      .map { _ -> AboutAppStep in AboutAppStep.safariViewController(url: Constants.Urls.kGitHubProjectIssuesUrl) }
      .bind(to: steps)
      .disposed(by: disposeBag)
    
    onDidPressReportIssueViaEmailCellButtonSubject
      .map { _ -> AboutAppStep in
        AboutAppStep.sendEmail(
          recipients: [Constants.EmailAdresses.mainContact],
          subject: R.string.localizable.app_name().append(contentsOf: R.string.localizable.report_issue(), delimiter: .custom(string: " - ")),
          message: R.string.localizable.email_salutation()
        )
      }
      .bind(to: steps)
      .disposed(by: disposeBag)
  }
}

// MARK: - Delegate Extensions

extension AboutAppViewModel: BaseTableViewSelectionDelegate {
  
  func didSelectRow(at indexPath: IndexPath) {
    _ = Observable.just(indexPath)
      .map { [unowned tableDataSource] indexPath in
        tableDataSource.sectionDataSources
          .value?[safe: indexPath.section]?
          .sectionItems[safe: indexPath.row]?
          .onSelectedRoutingIntent
      }
      .filterNil()
      .take(1)
      .asSingle()
      .subscribe(onSuccess: steps.accept)
  }
}

// MARK: - Helpers

// MARK: - Helper Extensions
