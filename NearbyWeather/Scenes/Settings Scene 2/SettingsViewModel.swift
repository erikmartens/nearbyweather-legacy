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
    let weatherStationService: WeatherStationBookmarkReading
    let preferencesService: SettingsPreferencesSetting & SettingsPreferencesReading
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
  
  // MARK: - Drivers
  
  // MARK: - Observables
  
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
    
    /// General Section
    let generalSectionItems: [BaseCellViewModelProtocol] = [
      SettingsImagedSingleLabelCellViewModel(dependencies: SettingsImagedSingleLabelCellViewModel.Dependencies(
        symbolImageBackgroundColor: Constants.Theme.Color.ViewElement.CellImage.blue,
        symbolImage: R.image.info(),
        labelText: R.string.localizable.about(),
        selectable: true,
        disclosable: true
      ))
    ]
    
    let generalSectionObservable = Observable.just(SettingsGeneralItemsSection(sectionItems: generalSectionItems))
    
    /// OpenWeatherMapApi Section
    let openWeatherMapApiSectionItems: [BaseCellViewModelProtocol] = [
      SettingsImagedSingleLabelCellViewModel(dependencies: SettingsImagedSingleLabelCellViewModel.Dependencies(
        symbolImageBackgroundColor: Constants.Theme.Color.ViewElement.CellImage.green,
        symbolImage: R.image.seal(),
        labelText: R.string.localizable.apiKey(),
        selectable: true,
        disclosable: true
      )),
      SettingsImagedSingleLabelCellViewModel(dependencies: SettingsImagedSingleLabelCellViewModel.Dependencies(
        symbolImageBackgroundColor: Constants.Theme.Color.ViewElement.CellImage.blue,
        symbolImage: R.image.start(),
        labelText: R.string.localizable.get_started_with_openweathermap(),
        selectable: true,
        disclosable: true
      ))
    ]
    
    let openWeatherMapApiSectionObservable = Observable.just(SettingsOpenWeatherMapApiItemsSection(sectionItems: openWeatherMapApiSectionItems))
    
    /// Bookmarks Section Main
    let amountOfBookmarksObservable = dependencies.weatherStationService.createGetBookmarkedStationsObservable().map { "\($0.count)" }
    
    let bookmarksMainSectionItems: [BaseCellViewModelProtocol] = [
      SettingsImagedDualLabelCellViewModel(dependencies: SettingsImagedDualLabelCellViewModel.Dependencies(
        symbolImageBackgroundColor: Constants.Theme.Color.ViewElement.CellImage.red,
        symbolImage: R.image.wrench(),
        contentLabelText: R.string.localizable.manage_locations(),
        descriptionLabelTextObservable: amountOfBookmarksObservable,
        selectable: true,
        disclosable: true
      )),
      SettingsImagedSingleLabelCellViewModel(dependencies: SettingsImagedSingleLabelCellViewModel.Dependencies(
        symbolImageBackgroundColor: Constants.Theme.Color.ViewElement.CellImage.red,
        symbolImage: R.image.add_bookmark(),
        labelText: R.string.localizable.manage_locations(),
        selectable: true,
        disclosable: true
      ))
    ]
    
    let bookmarksMainSectionObservable = Observable.just(SettingsBookmarksItemsMainSection(sectionItems: bookmarksMainSectionItems))
    
    /// Bookmarks Section Sub 1
    let allowTempOnAppIconObservable = dependencies.preferencesService.createGetShowTemperatureOnAppIconOptionObservable().map { $0.rawRepresentableValue }
    let preferredBookmarkNameObservable = dependencies.weatherStationService.createGetPreferredBookmarkObservable().map { $0?.stringValue ?? R.string.localizable.none() }
    
    let bookmarksSubSection1Items: [BaseCellViewModelProtocol] = [
      SettingsImagedSingleLabelToggleCellViewModel(dependencies: SettingsImagedSingleLabelToggleCellViewModel.Dependencies(
        symbolImageBackgroundColor: Constants.Theme.Color.ViewElement.CellImage.red,
        symbolImage: R.image.badge(),
        labelText: R.string.localizable.show_temp_on_icon(),
        isToggleOnObservable: allowTempOnAppIconObservable
      )),
      SettingsImagedDualLabelCellViewModel(dependencies: SettingsImagedDualLabelCellViewModel.Dependencies(
        symbolImageBackgroundColor: Constants.Theme.Color.ViewElement.CellImage.red,
        symbolImage: R.image.preferred_bookmark(),
        contentLabelText: R.string.localizable.preferred_bookmark(),
        descriptionLabelTextObservable: preferredBookmarkNameObservable,
        selectable: true,
        disclosable: false
      ))
    ]
    
    let bookmarksSubSection1Observable = Observable.just(SettingsBookmarksItemsSubSection1(sectionItems: bookmarksSubSection1Items))
    
    /// Preferences Section Main
    let refreshOnAppStartObservable = dependencies.preferencesService.createGetRefreshOnAppStartOptionObservable().map { $0.rawRepresentableValue }
    
    let preferencesMainSectionItems: [BaseCellViewModelProtocol] = [
      SettingsImagedSingleLabelToggleCellViewModel(dependencies: SettingsImagedSingleLabelToggleCellViewModel.Dependencies(
        symbolImageBackgroundColor: Constants.Theme.Color.ViewElement.CellImage.gray,
        symbolImage: R.image.reload(),
        labelText: R.string.localizable.refresh_on_app_start(),
        isToggleOnObservable: refreshOnAppStartObservable
      ))
    ]
    
    let preferencesMainSectionObservable = Observable.just(SettingsPreferencesItemsMainSection(sectionItems: preferencesMainSectionItems))
    
    /// Preferences Setion Sub 1
    let temperatureUnitPreferenceObservable = dependencies.preferencesService.createGetTemperatureUnitOptionObservable().map { $0.stringValue }
    let dimensionalUnitPreferenceObservable = dependencies.preferencesService.createGetDimensionalUnitsOptionObservable().map { $0.stringValue }
    
    let preferencesSubSection1Items: [BaseCellViewModelProtocol] = [
      SettingsImagedDualLabelCellViewModel(dependencies: SettingsImagedDualLabelCellViewModel.Dependencies(
        symbolImageBackgroundColor: Constants.Theme.Color.ViewElement.CellImage.gray,
        symbolImage: R.image.thermometer(),
        contentLabelText: R.string.localizable.temperature_unit(),
        descriptionLabelTextObservable: temperatureUnitPreferenceObservable,
        selectable: true,
        disclosable: false
      )),
      SettingsImagedDualLabelCellViewModel(dependencies: SettingsImagedDualLabelCellViewModel.Dependencies(
        symbolImageBackgroundColor: Constants.Theme.Color.ViewElement.CellImage.gray,
        symbolImage: R.image.dimension(),
        contentLabelText: R.string.localizable.distanceSpeed_unit(),
        descriptionLabelTextObservable: dimensionalUnitPreferenceObservable,
        selectable: true,
        disclosable: false
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
        resultSelector: { sect0, sect1, sect2, sect3, sect4, sect5 -> [TableViewSectionDataProtocol] in
          [sect0, sect1, sect2, sect3, sect4, sect5]
        }
      )
      .bind { [weak tableDataSource] in tableDataSource?.sectionDataSources.accept($0) }
      .disposed(by: disposeBag)
  }
  
  func observeUserTapEvents() {
    // nothing to do
  }
}

// MARK: - Delegate Extensions

extension SettingsViewModel: BaseTableViewSelectionDelegate {
  
  func didSelectRow(at indexPath: IndexPath) {
    
  }
}

// MARK: - Delegates

// MARK: - Helpers

private extension SettingsViewModel {
  
}

// MARK: - Helper Extensions
