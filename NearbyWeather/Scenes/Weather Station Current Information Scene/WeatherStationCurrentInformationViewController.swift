//
//  WeatherStationCurrentInformationViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 12.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxSwift

// MARK: - Definitions

private extension WeatherStationCurrentInformationViewController {
  struct Definitions {
  }
}

// MARK: - Class Definition

final class WeatherStationCurrentInformationViewController: UIViewController, BaseViewController {
  
  typealias ViewModel = WeatherStationCurrentInformationViewModel
  
  // MARK: - UIComponents
  
  fileprivate lazy var tableView = Factory.TableView.make(fromType: .standard(frame: view.frame))
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  let viewModel: ViewModel
  
  // MARK: - Initialization
  
  required init(dependencies: ViewModel.Dependencies) {
    viewModel = WeatherStationCurrentInformationViewModel(dependencies: dependencies)
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    printDebugMessage(
      domain: String(describing: self),
      message: "was deinitialized",
      type: .info
    )
  }
  
  // MARK: - ViewController LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel.viewDidLoad()
    setupUiComponents()
    setupBindings()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.viewWillAppear()
    setupUiAppearance()
  }
}

// MARK: - ViewModel Bindings

extension WeatherStationCurrentInformationViewController {
  
  func setupBindings() {
    viewModel.observeEvents()
    bindContentFromViewModel(viewModel)
    bindUserInputToViewModel(viewModel)
  }
  
  func bindContentFromViewModel(_ viewModel: ViewModel) {
    viewModel
      .navigationBarDriver
      .drive { [weak self] navigationBarInformation in
        guard let navigationTitle = navigationBarInformation.0,
              let barTintColor = navigationBarInformation.1,
              let tintColor = navigationBarInformation.2 else {
          return
        }
        self?.title = navigationTitle
        self?.navigationController?.navigationBar.style(withBarTintColor: barTintColor, tintColor: tintColor)
      }
      .disposed(by: disposeBag)
    
    viewModel
      .tableDataSource
      .sectionDataSources
      .map { _ in () }
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak tableView] in tableView?.reloadData() })
      .disposed(by: disposeBag)
  }
  
  func bindUserInputToViewModel(_ viewModel: ViewModel) {
    // nothing to do - will be used in the future
  }
}

// MARK: - Setup

private extension WeatherStationCurrentInformationViewController {
  
  func setupUiComponents() {
    tableView.dataSource = viewModel.tableDataSource
    tableView.delegate = viewModel.tableDelegate
    
    tableView.registerCells([
      WeatherStationCurrentInformationHeaderCell.self,
      WeatherStationCurrentInformationSunCycleCell.self,
      WeatherStationCurrentInformationAtmosphericDetailsCell.self,
      WeatherStationCurrentInformationWindCell.self,
      WeatherStationCurrentInformationMapCell.self
    ])
    
    tableView.contentInset = UIEdgeInsets(
      top: Constants.Dimensions.TableCellContentInsets.top,
      left: .zero,
      bottom: Constants.Dimensions.TableCellContentInsets.bottom,
      right: .zero
    )
    
    view.addSubview(tableView, constraints: [
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
  func setupUiAppearance() {
    view.backgroundColor = Constants.Theme.Color.ViewElement.secondaryBackground
    tableView.backgroundColor = .clear
  }
}
