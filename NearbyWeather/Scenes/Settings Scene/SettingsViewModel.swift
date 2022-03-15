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
        symbolImageBackgroundColor: Constants.Theme.Color.ViewElement.CellImage.blue,
        symbolImage: R.image.info(),
        labelText: R.string.localizable.about(),
        selectable: true,
        disclosable: true
      ))
    ]
    
    let generalSectionObservable = Observable.just(SettingsGeneralItemsSection(sectionItems: generalSectionItems))
    
    // OpenWeatherMapApi Section
    let openWeatherMapApiSectionItems: [BaseCellViewModelProtocol] = [
      SettingsImagedSingleLabelCellViewModel(dependencies: SettingsImagedSingleLabelCellViewModel.Dependencies(
        symbolImageBackgroundColor: Constants.Theme.Color.ViewElement.CellImage.green,
        symbolImage: R.image.seal(),
        labelText: R.string.localizable.apiKey(),
        selectable: true,
        disclosable: true
      )),
      SettingsImagedSingleLabelCellViewModel(dependencies: SettingsImagedSingleLabelCellViewModel.Dependencies(
        symbolImageBackgroundColor: Constants.Theme.Color.ViewElement.CellImage.green,
        symbolImage: R.image.start(),
        labelText: R.string.localizable.get_started_with_openweathermap(),
        selectable: true,
        disclosable: true
      ))
    ]
    
    let openWeatherMapApiSectionObservable = Observable.just(SettingsOpenWeatherMapApiItemsSection(sectionItems: openWeatherMapApiSectionItems))
    
    // Bookmarks Section Main
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
        labelText: R.string.localizable.add_location(),
        selectable: true,
        disclosable: true
      ))
    ]
    
    let bookmarksMainSectionObservable = Observable.just(SettingsBookmarksItemsMainSection(sectionItems: bookmarksMainSectionItems))
    
    // Bookmarks Section Sub 1
    let allowTempOnAppIconObservable = dependencies.preferencesService.createGetShowTemperatureOnAppIconOptionObservable().map { $0.rawRepresentableValue }
    let preferredBookmarkNameObservable = dependencies.weatherStationService.createGetPreferredBookmarkObservable().map { $0?.stringValue ?? R.string.localizable.none() }
    
    let bookmarksSubSection1Items: [BaseCellViewModelProtocol] = [
      SettingsImagedSingleLabelToggleCellViewModel(dependencies: SettingsImagedSingleLabelToggleCellViewModel.Dependencies(
        symbolImageBackgroundColor: Constants.Theme.Color.ViewElement.CellImage.red,
        symbolImage: R.image.badge(),
        labelText: R.string.localizable.show_temp_on_icon(),
        isToggleOnObservable: allowTempOnAppIconObservable,
        didFlipToggleSwitchSubject: onDidChangeAllowTempOnAppIconOptionSubject
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
    
    // Preferences Section Main
    let refreshOnAppStartObservable = dependencies.preferencesService.createGetRefreshOnAppStartOptionObservable().map { $0.rawRepresentableValue }
    
    let preferencesMainSectionItems: [BaseCellViewModelProtocol] = [
      SettingsImagedSingleLabelToggleCellViewModel(dependencies: SettingsImagedSingleLabelToggleCellViewModel.Dependencies(
        symbolImageBackgroundColor: Constants.Theme.Color.ViewElement.CellImage.gray,
        symbolImage: R.image.reload(),
        labelText: R.string.localizable.refresh_on_app_start(),
        isToggleOnObservable: refreshOnAppStartObservable,
        didFlipToggleSwitchSubject: onDidChangeRefreshOnAppStartOptionSubject
      ))
    ]
    
    let preferencesMainSectionObservable = Observable.just(SettingsPreferencesItemsMainSection(sectionItems: preferencesMainSectionItems))
    
    // Preferences Setion Sub 1
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
        resultSelector: { [$0, $1, $2, $3, $4, $5] }
      )
      .bind { [weak tableDataSource] in tableDataSource?.sectionDataSources.accept($0) }
      .disposed(by: disposeBag)
  }
  
  func observeUserTapEvents() {
    onDidChangeAllowTempOnAppIconOptionSubject
      .flatMapLatest { [dependencies] changedValue in
        dependencies.preferencesService
          .createSetShowTemperatureOnAppIconOptionCompletable(ShowTemperatureOnAppIconOption(value: changedValue ? .yes : .no))
          .asObservable()
      }
      .subscribe()
      .disposed(by: disposeBag)
    
    onDidChangeRefreshOnAppStartOptionSubject
      .flatMapLatest { [dependencies] changedValue in
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
    _ = Observable
      .just(indexPath)
      .map(mapIndexPathToRoutingIntent)
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

private extension SettingsViewModel {
  
  func mapIndexPathToRoutingIntent(_ indexPath: IndexPath) -> SettingsStep? { // swiftlint:disable:this cyclomatic_complexity
    switch indexPath.section {
    // General Section
    case 0:
      switch indexPath.row {
      case 0:
        return SettingsStep.about
      default:
        return nil
      }
    //  OpenWeatherMap Api Section
    case 1:
      switch indexPath.row {
      case 0:
        return SettingsStep.apiKeyEdit
      case 1:
        return SettingsStep.webBrowser(url: Constants.Urls.kOpenWeatherMapInstructionsUrl)
      default:
        return nil
      }
    //  Bookmarks Section Main
    case 2:
      switch indexPath.row {
      case 0:
        return SettingsStep.manageBookmarks
      case 1:
        return SettingsStep.addLocation
      default:
        return nil
      }
    //  Bookmarks Section Sub 1
    case 3:
      switch indexPath.row {
      case 0:
        return nil
      case 1:
        return SettingsStep.changePreferredBookmarkAlert(selectionDelegate: self)
      default:
        return nil
      }
    //  Preferences Section Main
    case 4:
      switch indexPath.row {
      case 0:
        return nil
      default:
        return nil
      }
    //  Preferences Section Sub 1
    case 5:
      switch indexPath.row {
      case 0:
        return SettingsStep.changeTemperatureUnitAlert(selectionDelegate: self)
      case 1:
        return SettingsStep.changeDimensionalUnitAlert(selectionDelegate: self)
      default:
        return nil
      }
    default:
      return nil
    }
  }
}

// MARK: - Helper Extensions
