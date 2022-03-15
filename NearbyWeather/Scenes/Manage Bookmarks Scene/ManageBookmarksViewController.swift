//
//  ManageBookmarksViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 15.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxSwift

// MARK: - Definitions

private extension ManageBookmarksViewController {
  struct Definitions {}
}

// MARK: - Class Definition

final class ManageBookmarksViewController: UIViewController, BaseViewController {
  
  typealias ViewModel = ManageBookmarksViewModel
  
  // MARK: - UIComponents
  
  fileprivate lazy var tableView = Factory.TableView.make(fromType: .standard(frame: view.frame))
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  let viewModel: ViewModel
  
  // MARK: - Initialization
  
  required init(dependencies: ViewModel.Dependencies) {
    viewModel = ManageBookmarksViewModel(dependencies: dependencies)
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

extension ManageBookmarksViewController {
  
  func setupBindings() {
    viewModel.observeEvents()
    bindContentFromViewModel(viewModel)
    bindUserInputToViewModel(viewModel)
  }
  
  func bindContentFromViewModel(_ viewModel: ViewModel) {
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

private extension ManageBookmarksViewController {
  
  func setupUiComponents() {
    tableView.dataSource = viewModel.tableDataSource
    tableView.delegate = viewModel.tableDelegate
    tableView.isEditing = true
    
    tableView.registerCells([
      SettingsSingleLabelCell.self
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
    title = R.string.localizable.manage_locations()
    view.backgroundColor = Constants.Theme.Color.ViewElement.secondaryBackground
  }
}
