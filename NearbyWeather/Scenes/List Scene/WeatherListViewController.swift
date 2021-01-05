//
//  WeatherListViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxSwift

private extension WeatherListViewController {
  struct Definitions {
    static let weatherInformationCellHeight: CGFloat = 100 // TODO: verify is correct
  }
}

final class WeatherListViewController: UIViewController, BaseViewController {
  
  typealias ViewModel = WeatherListViewModel
  
  // MARK: - UIComponents
  
  fileprivate lazy var listTypeBarButton = Factory.BarButtonItem.make(fromType: .standard(image: R.image.layerType()))
  fileprivate lazy var amountOfResultsBarButton = Factory.BarButtonItem.make(fromType: .standard())
  fileprivate lazy var sortingOrientationBarButton = Factory.BarButtonItem.make(fromType: .standard(image: R.image.sort()))
  
  fileprivate lazy var tableView = Factory.TableView.make(fromType: .standard(frame: view.frame))
  
  // MARK: - Properties
  
  let viewModel: ViewModel
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Initialization
  
  required init(dependencies: ViewModel.Dependencies) {
    viewModel = WeatherListViewModel(dependencies: dependencies)
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - ViewController LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel.viewDidLoad()
    setupLayout()
    setupBindings()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setupAppearance()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    tableView.refreshControl?.endRefreshing()
  }
}

// MARK: - ViewModel Bindings

private extension WeatherListViewController {
  
  func setupBindings() {
    viewModel.observeEvents()
    bindContentFromViewModel(viewModel)
    bindUserInputToViewModel(viewModel)
  }
  
  private func bindContentFromViewModel(_ viewModel: ViewModel) {
    viewModel
      .tableDataSource
      .sectionDataSources
      .map { _ in () }
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak self] in self?.tableView.reloadData() })
      .disposed(by: disposeBag)
    
    viewModel
      .preferredListTypeDriver
      .drive(onNext: { [weak navigationItem, weak amountOfResultsBarButton, weak sortingOrientationBarButton] listTypeValue in
        switch listTypeValue {
        case .bookmarked:
          navigationItem?.rightBarButtonItems = []
        case .nearby:
          if let amountOfResultsBarButton = amountOfResultsBarButton, let sortingOrientationBarButton = sortingOrientationBarButton {
            navigationItem?.rightBarButtonItems = [amountOfResultsBarButton, sortingOrientationBarButton]
          }
        }
      })
      .disposed(by: disposeBag)
    
    viewModel
      .preferredAmountOfResultsDriver
      .drive(onNext: { [weak amountOfResultsBarButton] amountOfResultsValue in
        amountOfResultsBarButton?.setBackgroundImage(
          AmountOfResultsOption(value: amountOfResultsValue).imageValue,
          for: UIControl.State(),
          barMetrics: .default
        )
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
  
  private func bindUserInputToViewModel(_ viewModel: ViewModel) {
    listTypeBarButton.rx
      .tap
      .bind(to: viewModel.onDidTapListTypeBarButtonSubject)
      .disposed(by: disposeBag)
    
    amountOfResultsBarButton.rx
      .tap
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
  
  func setupLayout() {
    tableView.dataSource = viewModel.tableDataSource
    tableView.delegate = viewModel.tableDelegate
    tableView.estimatedRowHeight = Definitions.weatherInformationCellHeight
    
    tableView.refreshControl = UIRefreshControl()
    
    tableView.registerCells([
      WeatherListTableViewCell.self // TODO: also register Alert Cell
    ])
    
    tableView.contentInset = UIEdgeInsets(
      top: Constants.Dimensions.TableCellContentInsets.top,
      left: .zero,
      bottom: Constants.Dimensions.TableCellContentInsets.bottom,
      right: .zero
    )
    
    view?.addSubview(tableView, constraints: [
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
  func setupAppearance() {
    view.backgroundColor = Constants.Theme.Color.ViewElement.primaryBackground
  }
}
