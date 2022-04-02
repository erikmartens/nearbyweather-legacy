//
//  SettingsViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 06.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa
import RxFlow
import CoreLocation

// MARK: - Dependencies

extension SettingsViewModel {
  struct Dependencies {
    let weatherStationService: WeatherStationBookmarkReading & WeatherStationBookmarkSetting
    let preferencesService: SettingsPreferencesSetting & SettingsPreferencesReading
    let notificationService: NotificationPreferencesSetting & NotificationPreferencesReading
  }
}

// MARK: - Class Definition

final class SettingsViewModel: NSObject, Stepper, BaseViewModel {
  
  // MARK: - Routing
  
  let steps = PublishRelay<Step>()
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  var tableDelegate: SettingsTableViewDelegate? // swiftlint:disable:this weak_delegate
  let tableDataSource: SettingsTableViewDataSource
  
  // MARK: - Events
  
  let onDidChangeAllowTempOnAppIconOptionSubject = PublishSubject<Bool>()
  let onDidChangeRefreshOnAppStartOptionSubject = PublishSubject<Bool>()
  
  // MARK: - Drivers
  
  // MARK: - Observables
  
  private lazy var amountOfBookmarksObservable = dependencies.weatherStationService
    .createGetBookmarkedStationsObservable()
    .map { $0.count }
    .share(replay: 1)
  
  private lazy var allowTempOnAppIconObservable = dependencies.notificationService
    .createGetShowTemperatureOnAppIconOptionObservable()
    .map { $0.rawRepresentableValue }
    .share(replay: 1)
  
  // MARK: - Initialization
  
  required init(dependencies: Dependencies) {
    self.dependencies = dependencies
    tableDataSource = SettingsTableViewDataSource()
    super.init()
    
    tableDelegate = SettingsTableViewDelegate(cellSelectionDelegate: self)
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

extension SettingsViewModel {

  func observeDataSource() {
    
    // General Section
    let generalSectionItems: [BaseCellViewModelProtocol] = [
      SettingsImagedSingleLabelCellViewModel(dependencies: SettingsImagedSingleLabelCellViewModel.Dependencies(
        symbolImageBackgroundColor: Constants.Theme.Color.ViewElement.CellImage.backgroundBlue,
        symbolImageName: "info.circle.fill",
        labelText: R.string.localizable.about(),
        selectable: true,
        disclosable: true,
        routingIntent: SettingsStep.about
      ))
    ]
    
    let generalSectionObservable = Observable.just(SettingsGeneralItemsSection(sectionItems: generalSectionItems))
    
    // OpenWeatherMapApi Section
    let openWeatherMapApiSectionItems: [BaseCellViewModelProtocol] = [
      SettingsImagedSingleLabelCellViewModel(dependencies: SettingsImagedSingleLabelCellViewModel.Dependencies(
        symbolImageBackgroundColor: Constants.Theme.Color.ViewElement.CellImage.backgroundGreen,
        symbolImageName: "checkmark.seal.fill",
        labelText: R.string.localizable.apiKey(),
        selectable: true,
        disclosable: true,
        routingIntent: SettingsStep.apiKeyEdit
      )),
      SettingsImagedSingleLabelCellViewModel(dependencies: SettingsImagedSingleLabelCellViewModel.Dependencies(
        symbolImageBackgroundColor: Constants.Theme.Color.ViewElement.CellImage.backgroundYellow.darken(by: 10),
        symbolImageName: "lightbulb.fill",
        labelText: R.string.localizable.get_started_with_openweathermap(),
        selectable: true,
        disclosable: true,
        routingIntent: SettingsStep.webBrowser(url: Constants.Urls.kOpenWeatherMapInstructionsUrl)
      ))
    ]
    
    let openWeatherMapApiSectionObservable = Observable.just(SettingsOpenWeatherMapApiItemsSection(sectionItems: openWeatherMapApiSectionItems))
    
    // Bookmarks Section Main
    let manageBoomarksCell = SettingsImagedDualLabelCellViewModel(dependencies: SettingsImagedDualLabelCellViewModel.Dependencies(
      symbolImageBackgroundColor: Constants.Theme.Color.ViewElement.CellImage.backgroundRed,
      symbolImageName: "wrench.fill",
      contentLabelText: R.string.localizable.manage_locations(),
      descriptionLabelTextObservable: amountOfBookmarksObservable.map { "\($0)" },
      selectable: true,
      disclosable: true,
      routingIntent: SettingsStep.manageBookmarks
    ))
    
    let addBookmarkCell = SettingsImagedSingleLabelCellViewModel(dependencies: SettingsImagedSingleLabelCellViewModel.Dependencies(
      symbolImageBackgroundColor: Constants.Theme.Color.ViewElement.CellImage.backgroundRed,
      symbolImageName: "plus.square.fill",
      labelText: R.string.localizable.add_location(),
      selectable: true,
      disclosable: true,
      routingIntent: SettingsStep.addBookmark
    ))
    
    let bookmarksMainSectionObservable = amountOfBookmarksObservable
      .map { $0 > 0 ? [manageBoomarksCell, addBookmarkCell] : [addBookmarkCell] }
      .map(SettingsBookmarksItemsMainSection.init)
    
    // Bookmarks Section Sub 1
    let preferredBookmarkNameObservable = dependencies.weatherStationService
      .createGetPreferredBookmarkObservable()
      .materialize()
      .map { ($0.element as? PreferredBookmarkOption)?.stringValue ?? R.string.localizable.none() }
      .share(replay: 1)
    
    let temperatureViaAppIconCell = SettingsImagedSingleLabelToggleCellViewModel(dependencies: SettingsImagedSingleLabelToggleCellViewModel.Dependencies(
      symbolImageBackgroundColor: Constants.Theme.Color.ViewElement.CellImage.backgroundRed,
      symbolImageName: "app.badge",
      labelText: R.string.localizable.show_temp_on_icon(),
      isToggleOnObservable: allowTempOnAppIconObservable,
      didFlipToggleSwitchSubject: onDidChangeAllowTempOnAppIconOptionSubject
    ))
    let preferredBookmarkCell = SettingsImagedDualLabelSubtitleCellViewModel(dependencies: SettingsImagedDualLabelSubtitleCellViewModel.Dependencies(
      symbolImageBackgroundColor: Constants.Theme.Color.ViewElement.CellImage.backgroundRed,
      symbolImageName: "star.square.fill",
      contentLabelText: R.string.localizable.preferred_bookmark(),
      descriptionLabelTextObservable: preferredBookmarkNameObservable,
      selectable: true,
      disclosable: false,
      routingIntent: SettingsStep.changePreferredBookmarkAlert(selectionDelegate: self)
    ))
    
    let bookmarksSubSection1Observable = Observable
      .combineLatest(
        amountOfBookmarksObservable,
        allowTempOnAppIconObservable,
        resultSelector: { amountOfBookmarks, allowTempOnAppIcon -> [BaseCellViewModelProtocol] in
          guard amountOfBookmarks > 0 else {
            return []
          }
          guard allowTempOnAppIcon else {
            return [temperatureViaAppIconCell]
          }
          return [temperatureViaAppIconCell, preferredBookmarkCell]
        }
      )
      .map(SettingsBookmarksItemsSubSection1.init)
    
    // Preferences Section Main
    let refreshOnAppStartObservable = dependencies.preferencesService
      .createGetRefreshOnAppStartOptionObservable()
      .map { $0.rawRepresentableValue }
      .share(replay: 1)
    
    let preferencesMainSectionItems: [BaseCellViewModelProtocol] = [
      SettingsImagedSingleLabelToggleCellViewModel(dependencies: SettingsImagedSingleLabelToggleCellViewModel.Dependencies(
        symbolImageBackgroundColor: Constants.Theme.Color.ViewElement.CellImage.backgroundGray,
        symbolImageName: "arrow.counterclockwise.circle.fill",
        labelText: R.string.localizable.refresh_on_app_start(),
        isToggleOnObservable: refreshOnAppStartObservable,
        didFlipToggleSwitchSubject: onDidChangeRefreshOnAppStartOptionSubject
      ))
    ]
    
    let preferencesMainSectionObservable = Observable.just(SettingsPreferencesItemsMainSection(sectionItems: preferencesMainSectionItems))
    
    // Preferences Section Sub 1
    let temperatureUnitPreferenceObservable = dependencies.preferencesService.createGetTemperatureUnitOptionObservable().map { $0.stringValue }
    let dimensionalUnitPreferenceObservable = dependencies.preferencesService.createGetDimensionalUnitsOptionObservable().map { $0.stringValue }
    
    let preferencesSubSection1Items: [BaseCellViewModelProtocol] = [
      SettingsImagedDualLabelCellViewModel(dependencies: SettingsImagedDualLabelCellViewModel.Dependencies(
        symbolImageBackgroundColor: Constants.Theme.Color.ViewElement.CellImage.backgroundGray,
        symbolImageName: "thermometer",
        contentLabelText: R.string.localizable.temperature_unit(),
        descriptionLabelTextObservable: temperatureUnitPreferenceObservable,
        selectable: true,
        disclosable: false,
        routingIntent: SettingsStep.changeTemperatureUnitAlert(selectionDelegate: self)
      )),
      SettingsImagedDualLabelCellViewModel(dependencies: SettingsImagedDualLabelCellViewModel.Dependencies(
        symbolImageBackgroundColor: Constants.Theme.Color.ViewElement.CellImage.backgroundGray,
        symbolImageName: "ruler.fill",
        contentLabelText: R.string.localizable.distanceSpeed_unit(),
        descriptionLabelTextObservable: dimensionalUnitPreferenceObservable,
        selectable: true,
        disclosable: false,
        routingIntent: SettingsStep.changeDimensionalUnitAlert(selectionDelegate: self)
      ))
    ]
    
    let preferencesSubSection1Observable = Observable.just(SettingsPreferencesItemsSubSection1(sectionItems: preferencesSubSection1Items))
    
    Observable
      .combineLatest(
        generalSectionObservable,
        openWeatherMapApiSectionObservable,
        bookmarksMainSectionObservable,
        bookmarksSubSection1Observable,
        preferencesMainSectionObservable,
        preferencesSubSection1Observable,
        resultSelector: { [$0, $1, $2, $3, $4, $5] }
      )
      .map { $0.compactMap { $0.sectionItems.isEmpty ? nil : $0 } } // remove empty sections
      .bind { [weak tableDataSource] in tableDataSource?.sectionDataSources.accept($0) }
      .disposed(by: disposeBag)
  }
  
  func observeUserTapEvents() {
    onDidChangeAllowTempOnAppIconOptionSubject
      .flatMapLatest { [unowned self] changedValue in
        dependencies.notificationService
          .createSetShowTemperatureOnAppIconOptionCompletable(ShowTemperatureOnAppIconOption(value: changedValue ? .yes : .no))
          .asObservable()
      }
      .subscribe()
      .disposed(by: disposeBag)
    
    onDidChangeRefreshOnAppStartOptionSubject
      .flatMapLatest { [unowned self] changedValue in
        dependencies.preferencesService
          .createSetRefreshOnAppStartOptionCompletable(RefreshOnAppStartOption(value: changedValue ? .yes : .no))
          .asObservable()
      }
      .subscribe()
      .disposed(by: disposeBag)
  }
}

// MARK: - Delegate Extensions

extension SettingsViewModel: BaseTableViewSelectionDelegate {
  
  func didSelectRow(at indexPath: IndexPath) {
    _ = Observable.just(indexPath)
      .map { [weak tableDataSource] indexPath in
        tableDataSource?.sectionDataSources[indexPath]?.onSelectedRoutingIntent
      }
      .filterNil()
      .take(1)
      .asSingle()
      .subscribe(onSuccess: steps.accept)
  }
}

extension SettingsViewModel: PreferredBookmarkSelectionAlertDelegate {
  
  func didSelectPreferredBookmarkOption(_ option: PreferredBookmarkOption) {
    _ = dependencies.weatherStationService
      .createSetPreferredBookmarkCompletable(option)
      .subscribe()
  }
}

extension SettingsViewModel: TemperatureUnitSelectionAlertDelegate {
  
  func didSelectTemperatureUnitOption(_ selectedOption: TemperatureUnitOption) {
    _ = dependencies.preferencesService
      .createSetTemperatureUnitOptionCompletable(selectedOption)
      .subscribe()
  }
}

extension SettingsViewModel: DimensionalUnitSelectionAlertDelegate {
  
  func didSelectDimensionalUnitOption(_ selectedOption: DimensionalUnitOption) {
    _ = dependencies.preferencesService
      .createSetDimensionalUnitsOptionCompletable(selectedOption)
      .subscribe()
  }
}

// MARK: - Helpers

// MARK: - Helper Extensions
