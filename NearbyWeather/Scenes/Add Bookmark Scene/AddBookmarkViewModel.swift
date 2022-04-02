//
//  AddBookmarkViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 12.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa
import RxFlow
import PKHUD

// MARK: - Dependencies

extension AddBookmarkViewModel {
  struct Dependencies {
    let weatherStationService: WeatherStationBookmarkSetting & WeatherStationBookmarkReading & WeatherStationLookup
  }
}

// MARK: - Class Definition

final class AddBookmarkViewModel: NSObject, Stepper, BaseViewModel {
  
  // MARK: - Routing
  
  let steps = PublishRelay<Step>()
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  var tableDelegate: AddBookmarkTableViewDelegate? // swiftlint:disable:this weak_delegate
  let tableDataSource: AddBookmarkTableViewDataSource
  
  // MARK: - Events
  
  let searchFieldTextSubject = PublishSubject<String?>()
  private let searchResultsSubject = BehaviorSubject<[WeatherStationDTO]>(value: [])
  
  // MARK: - Drivers
  
  // MARK: - Observables
  
  // MARK: - Initialization
  
  required init(dependencies: Dependencies) {
    self.dependencies = dependencies
    tableDataSource = AddBookmarkTableViewDataSource()
    super.init()
    
    tableDelegate = AddBookmarkTableViewDelegate(cellSelectionDelegate: self)
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

extension AddBookmarkViewModel {

  func observeDataSource() {
    searchFieldTextSubject.asObservable()
      .filterNil()
      .filterEmpty()
      .flatMapLatest(dependencies.weatherStationService.createWeatherStationsLocalLookupObservable)
      .bind(to: searchResultsSubject)
      .disposed(by: disposeBag)
    
    searchResultsSubject
      .map { weatherStationDtos -> [SettingsDualLabelSubtitleCellViewModel] in
        weatherStationDtos.map {
          let countryName = MeteorologyInformationConversionWorker.countryName(for: $0.country) ?? ""
          let subtitleText: String
          if let usStateCode = $0.state {
            subtitleText = String
              .begin()
              .append(contentsOf: MeteorologyInformationConversionWorker.usStateName(for: usStateCode), delimiter: .none) // only US states have state codes attached
              .append(contentsOf: countryName, delimiter: .comma)
          } else {
            subtitleText = countryName
          }
          
          return SettingsDualLabelSubtitleCellViewModel(dependencies: SettingsDualLabelSubtitleCellViewModel.Dependencies(
            contentLabelText: $0.name,
            subtitleLabelText: subtitleText,
            selectable: true,
            disclosable: false,
            routingIntent: nil
          ))
        }
      }
      .map(AddBookmarkSearchResultsSection.init)
      .map { [$0] }
      .bind { [weak tableDataSource] in tableDataSource?.sectionDataSources.accept($0) }
      .disposed(by: disposeBag)
  }
}

// MARK: - Delegate Extensions

extension AddBookmarkViewModel: BaseTableViewSelectionDelegate {
  
  func didSelectRow(at indexPath: IndexPath) {
    Observable
      .just(indexPath.row)
      .flatMapLatest { [unowned searchResultsSubject] row -> Observable<WeatherStationDTO?> in
        searchResultsSubject.asObservable().take(1).map { $0[safe: row] }
      }
      .filterNil()
      .do(onNext: { [dependencies] weatherStationDto in
        _ = dependencies.weatherStationService
          .createAddBookmarkCompletable(weatherStationDto)
          .do(
            onError: { _ in DispatchQueue.main.async { HUD.flash(.error, delay: 1.0) } },
            onCompleted: { DispatchQueue.main.async { HUD.flash(.success, delay: 1.0) } }
          )
          .subscribe()
      })
      .map { _ -> AddBookmarkStep in AddBookmarkStep.end }
      .bind(to: steps)
      .disposed(by: disposeBag)
  }
}

// MARK: - Helpers

// MARK: - Helper Extensions
