//
//  AddBookmarkViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 12.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxSwift

// MARK: - Definitions

private extension AddBookmarkViewController {
  struct Definitions {}
}

// MARK: - Class Definition

final class AddBookmarkViewController: UIViewController, BaseViewController {
  
  typealias ViewModel = AddBookmarkViewModel
  
  // MARK: - UIComponents
  
  fileprivate lazy var searchController: UISearchController = {
    let searchController = UISearchController(searchResultsController: nil)
    searchController.searchBar.placeholder = R.string.localizable.search_by_name()
    searchController.hidesNavigationBarDuringPresentation = false
    return searchController
  }()
  
  fileprivate lazy var tableView = Factory.TableView.make(fromType: .standard(frame: view.frame))
  
  // MARK: - Assets
  
  private var disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  let viewModel: ViewModel
  
  // MARK: - Initialization
  
  required init(dependencies: ViewModel.Dependencies) {
    viewModel = AddBookmarkViewModel(dependencies: dependencies)
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
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    viewModel.viewDidAppear()
    
    searchController.isActive = true
    DispatchQueue.main.async {
      self.searchController.searchBar.becomeFirstResponder()
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    viewModel.viewWillDisappear()
    
    searchController.isActive = false
    searchController.resignFirstResponder()
    
    destroyBindings()
  }
}

// MARK: - ViewModel Bindings

extension AddBookmarkViewController {
  
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
      .tableDataSource
      .sectionDataSources
      .map { _ in () }
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak tableView] in tableView?.reloadData() })
      .disposed(by: disposeBag)
  }
  
  func bindUserInputToViewModel(_ viewModel: ViewModel) {
    searchController.searchBar.rx
      .value
      .bind(to: viewModel.searchFieldTextSubject)
      .disposed(by: disposeBag)
  }
}

// MARK: - Setup

private extension AddBookmarkViewController {
  
  func setupUiComponents() {
    navigationItem.searchController = searchController
    
    tableView.dataSource = viewModel.tableDataSource
    tableView.delegate = viewModel.tableDelegate
    
    tableView.registerCells([
      SettingsDualLabelSubtitleCell.self
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
    title = R.string.localizable.add_location()
    view.backgroundColor = Constants.Theme.Color.ViewElement.secondaryBackground
    
    navigationItem.hidesSearchBarWhenScrolling = false
  }
}
