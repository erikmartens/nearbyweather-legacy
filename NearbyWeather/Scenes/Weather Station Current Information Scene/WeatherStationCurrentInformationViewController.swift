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
      .navigationBarColorDriver
      .drive { [weak navigationController] colorTuple in
        guard let barTintColor = colorTuple.0,
              let tintColor = colorTuple.1 else {
          return
        }
        navigationController?.navigationBar.style(withBarTintColor: barTintColor, tintColor: tintColor)
      }
      .disposed(by: disposeBag)
    
    viewModel
      .tableDataSource
      .sectionDataSources
      .map { _ in () }
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak self] in self?.tableView.reloadData() })
      .disposed(by: disposeBag)
  }
  
  func bindUserInputToViewModel(_ viewModel: ViewModel) {} // nothing to do - will be used in the future
}

// MARK: - Setup

private extension WeatherStationCurrentInformationViewController {
  
  func setupUiComponents() {} // nothing to do - will be used in the future
  
  func setupUiAppearance() {
    view.backgroundColor = Constants.Theme.Color.ViewElement.primaryBackground
  }
}
