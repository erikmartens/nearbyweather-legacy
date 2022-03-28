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

private extension WeatherStationMeteorologyDetailsViewController {
  struct Definitions {
  }
}

// MARK: - Class Definition

final class WeatherStationMeteorologyDetailsViewController: UIViewController, BaseViewController {
  
  typealias ViewModel = WeatherStationMeteorologyDetailsViewModel
  
  // MARK: - UIComponents
  
  fileprivate lazy var tableView = Factory.TableView.make(fromType: .standard(frame: view.frame))
  
  // MARK: - Assets
  
  private var disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  let viewModel: ViewModel
  
  // MARK: - Initialization
  
  required init(dependencies: ViewModel.Dependencies) {
    viewModel = WeatherStationMeteorologyDetailsViewModel(dependencies: dependencies)
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
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.viewWillAppear()
    setupUiAppearance()
    setupBindings()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    viewModel.viewWillDisappear()
    destroyBindings()
  }
}

// MARK: - ViewModel Bindings

extension WeatherStationMeteorologyDetailsViewController {
  
  func setupBindings() {
    viewModel.observeEvents()
    bindContentFromViewModel(viewModel)
    bindUserInputToViewModel(viewModel)
  }
  
  func destroyBindings() {
    disposeBag = DisposeBag()
    viewModel.disregardEvents()
  }
  
  func bindContentFromViewModel(_ viewModel: ViewModel) {
    viewModel
      .navigationBarTitleDriver
      .drive { [unowned self] navigationTitle in title = navigationTitle }
      .disposed(by: disposeBag)
    
    viewModel
      .tableDataSource
      .sectionDataSources
      .map { _ in () }
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak tableView] in tableView?.reloadData() })
      .disposed(by: disposeBag)
  }
}

// MARK: - Setup

private extension WeatherStationMeteorologyDetailsViewController {
  
  func setupUiComponents() {
    tableView.dataSource = viewModel.tableDataSource
    tableView.delegate = viewModel.tableDelegate
    
    tableView.registerCells([
      WeatherStationMeteorologyDetailsHeaderCell.self,
      WeatherStationMeteorologyDetailsSunCycleCell.self,
      WeatherStationMeteorologyDetailsAtmosphericDetailsCell.self,
      WeatherStationMeteorologyDetailsWindCell.self,
      WeatherStationMeteorologyDetailsMapCell.self
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
