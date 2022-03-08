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
    let generalSectionItems: [BaseCellViewModelProtocol] = [
      SettingsImagedSingleLabelCellViewModel(dependencies: SettingsImagedSingleLabelCellViewModel.Dependencies(
        symbolImageBackgroundColor: Constants.Theme.Color.ViewElement.CellImage.blue,
        symbolImage: R.image.info(),
        labelText: R.string.localizable.about(),
        selectable: true,
        disclosable: true
      ))
    ]
    
    let generalSectionObservable = Observable.just(SettingsGeneralItemsSection(
      sectionHeaderTitle: R.string.localizable.general(),
      sectionCellsIdentifier: nil,
      sectionCellsIdentifiers: [SettingsImagedSingleLabelCell.reuseIdentifier],
      sectionItems: generalSectionItems
    ))
    
//    Observable
//      .combineLatest(
//        generalSectionObservable,
//        Observable.just([]),
//        Observable.just([]),
//        Observable.just([]),
//        Observable.just([]),
//        Observable.just([]),
//        resultSelector: { sect0, sect1, sect2, sect3, sect4, sect5 -> [TableViewSectionDataProtocol] in
//          [sect0, sect1, sect2, sect3, sect4, sect5]
//        }
//      )
//      .bind { [weak tableDataSource] in tableDataSource?.sectionDataSources.accept($0) }
//      .disposed(by: disposeBag)
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
