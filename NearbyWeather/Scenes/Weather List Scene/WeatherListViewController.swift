//
//  WeatherListViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxSwift

// MARK: - Definitions

private extension WeatherListViewController {
  struct Definitions {}
}

// MARK: - Class Definition

final class WeatherListViewController: UIViewController, BaseViewController {
  
  typealias ViewModel = WeatherListViewModel
  
  // MARK: - UIComponents
  
  fileprivate lazy var listTypeBarButton = Factory.BarButtonItem.make(fromType: .standard(image: R.image.layerType()))
  fileprivate lazy var sortingOrientationBarButton = Factory.BarButtonItem.make(fromType: .standard(image: R.image.sort()))
  
  fileprivate lazy var amountOfResultsBarButton10 = Factory.BarButtonItem.make(fromType: .standard(image: R.image.ten()))
  fileprivate lazy var amountOfResultsBarButton20 = Factory.BarButtonItem.make(fromType: .standard(image: R.image.twenty()))
  fileprivate lazy var amountOfResultsBarButton30 = Factory.BarButtonItem.make(fromType: .standard(image: R.image.thirty()))
  fileprivate lazy var amountOfResultsBarButton40 = Factory.BarButtonItem.make(fromType: .standard(image: R.image.forty()))
  fileprivate lazy var amountOfResultsBarButton50 = Factory.BarButtonItem.make(fromType: .standard(image: R.image.fifty()))
  
  fileprivate lazy var tableView = Factory.TableView.make(fromType: .standard(frame: view.frame))
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  let viewModel: ViewModel
  
  // MARK: - Initialization
  
  required init(dependencies: ViewModel.Dependencies) {
    viewModel = WeatherListViewModel(dependencies: dependencies)
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
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    viewModel.viewWillDisappear()
    tableView.refreshControl?.endRefreshing()
  }
}

// MARK: - ViewModel Bindings

extension WeatherListViewController {
  
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
    
    Observable
      .combineLatest(
        viewModel.preferredListTypeDriver.asObservable(),
        viewModel.preferredAmountOfResultsDriver.asObservable(),
        resultSelector: { ($0, $1) }
      )
      .asDriver(onErrorJustReturn: (ListTypeOptionValue.bookmarked, AmountOfResultsOptionValue.ten))
      .drive(onNext: { [unowned self] result in
        guard result.0 != .bookmarked else {
          self.navigationItem.rightBarButtonItems = []
          return
        }
        switch result.1 {
        case .ten:
          self.navigationItem.rightBarButtonItems = [self.amountOfResultsBarButton10, self.sortingOrientationBarButton]
        case .twenty:
          self.navigationItem.rightBarButtonItems = [self.amountOfResultsBarButton20, self.sortingOrientationBarButton]
        case .thirty:
          self.navigationItem.rightBarButtonItems = [self.amountOfResultsBarButton30, self.sortingOrientationBarButton]
        case .forty:
          self.navigationItem.rightBarButtonItems = [self.amountOfResultsBarButton40, self.sortingOrientationBarButton]
        case .fifty:
          self.navigationItem.rightBarButtonItems = [self.amountOfResultsBarButton50, self.sortingOrientationBarButton]
        }
      })
      .disposed(by: disposeBag)
    
    viewModel
      .isRefreshingDriver
      .drive(onNext: { [weak tableView] isRefreshing in
        isRefreshing
          ? tableView?.refreshControl?.beginRefreshing()
          : tableView?.refreshControl?.endRefreshing()
      })
      .disposed(by: disposeBag)
  }
  
  func bindUserInputToViewModel(_ viewModel: ViewModel) {
    listTypeBarButton.rx
      .tap
      .bind(to: viewModel.onDidTapListTypeBarButtonSubject)
      .disposed(by: disposeBag)
    
    Observable
      .merge(
        amountOfResultsBarButton10.rx.tap.asObservable(),
        amountOfResultsBarButton20.rx.tap.asObservable(),
        amountOfResultsBarButton30.rx.tap.asObservable(),
        amountOfResultsBarButton40.rx.tap.asObservable(),
        amountOfResultsBarButton50.rx.tap.asObservable()
      )
      .bind(to: viewModel.onDidTapAmountOfResultsBarButtonSubject)
      .disposed(by: disposeBag)
    
    sortingOrientationBarButton.rx
      .tap
      .bind(to: viewModel.onDidTapSortingOrientationBarButtonSubject)
      .disposed(by: disposeBag)
    
    tableView.refreshControl?.rx
      .controlEvent(.valueChanged)
      .bind(to: viewModel.onDidPullToRefreshSubject)
      .disposed(by: disposeBag)
  }
}

// MARK: - Setup

private extension WeatherListViewController {
  
  func setupUiComponents() {
    navigationItem.leftBarButtonItems = [listTypeBarButton]
    
    tableView.dataSource = viewModel.tableDataSource
    tableView.delegate = viewModel.tableDelegate
    
    tableView.refreshControl = UIRefreshControl()
    
    tableView.registerCells([
      WeatherListInformationTableViewCell.self,
      WeatherListAlertTableViewCell.self
    ])
    
    tableView.contentInset = UIEdgeInsets(
      top: .zero,
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
    title = R.string.localizable.tab_weatherList()
    
    view.backgroundColor = Constants.Theme.Color.ViewElement.secondaryBackground
    tableView.separatorStyle = .none
    tableView.backgroundColor = .clear
  }
}
