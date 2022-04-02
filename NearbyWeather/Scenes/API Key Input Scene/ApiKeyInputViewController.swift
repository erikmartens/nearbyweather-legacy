//
//  ApiKeyInputViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxSwift

// MARK: - Definitions

private extension ApiKeyInputViewController {
  struct Definitions {}
}

// MARK: - Class Definition

final class ApiKeyInputViewController: UIViewController, BaseViewController {
  
  typealias ViewModel = ApiKeyInputViewModel
  
  // MARK: - UIComponents
  
  fileprivate lazy var saveBarButtonItem = Factory.BarButtonItem.make(fromType: .standard(title: R.string.localizable.save(), color: Constants.Theme.Color.MarqueColors.standardMarque, style: .done))
  fileprivate lazy var tableView = Factory.TableView.make(fromType: .standard(frame: view.frame))
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  let viewModel: ViewModel
  private lazy var textEntryCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SettingsTextEntryCell
  
  // MARK: - Initialization
  
  required init(dependencies: ViewModel.Dependencies) {
    viewModel = ApiKeyInputViewModel(dependencies: dependencies)
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
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    viewModel.viewDidAppear()
    
    DispatchQueue.main.async {
      self.textEntryCell?.textEntryTextField.becomeFirstResponder()
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    viewModel.viewWillDisappear()
    
    DispatchQueue.main.async {
      self.textEntryCell?.textEntryTextField.resignFirstResponder()
    }
  }
}

// MARK: - ViewModel Bindings

extension ApiKeyInputViewController {
  
  func setupBindings() {
    viewModel.observeEvents()
    bindContentFromViewModel(viewModel)
    bindUserInputToViewModel(viewModel)
  }
  
  func bindContentFromViewModel(_ viewModel: ViewModel) {
    viewModel
      .saveBarButtonIsEnabledDriver
      .drive(onNext: { [weak saveBarButtonItem] isEnabled in saveBarButtonItem?.isEnabled = isEnabled })
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
    saveBarButtonItem.rx
      .tap
      .bind(to: viewModel.onDidTapSaveBarButtonSubject)
      .disposed(by: disposeBag)
  }
}

// MARK: - Setup

private extension ApiKeyInputViewController {
  
  func setupUiComponents() {
    navigationItem.rightBarButtonItems = [saveBarButtonItem]
    
    tableView.dataSource = viewModel.tableDataSource
    tableView.delegate = viewModel.tableDelegate
    
    tableView.registerCells([
      SettingsTextEntryCell.self
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
    navigationItem.largeTitleDisplayMode = .never
    
    title = R.string.localizable.api_settings()
    
    tabBarController?.tabBar.isTranslucent = true
    navigationController?.navigationBar.isTranslucent = true
    navigationController?.view.backgroundColor = Constants.Theme.Color.ViewElement.secondaryBackground
    view.backgroundColor = Constants.Theme.Color.ViewElement.secondaryBackground
  }
}
