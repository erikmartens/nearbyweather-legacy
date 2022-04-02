//
//  ListErrorViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 15.02.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxSwift

// MARK: - Definitions

private extension WeatherListErrorViewController {
  struct Definitions {
    static let mainStackViewInterElementYSpacing: CGFloat = 48
  }
}

// MARK: - Class Definition

final class WeatherListErrorViewController: UIViewController, BaseViewController {
  
  typealias ViewModel = WeatherListErrorViewModel
  private typealias ContentInsets = Constants.Dimensions.Spacing.ContentInsets
  
  // MARK: - UIComponents
  
  fileprivate lazy var mainContentStackView = Factory.StackView.make(fromType: .vertical(alignment: .center, distribution: .equalSpacing, spacingWeight: .custom(value: Definitions.mainStackViewInterElementYSpacing)))
  fileprivate lazy var textStackView = Factory.StackView.make(fromType: .vertical(distribution: .equalSpacing, spacingWeight: .medium))
  
  fileprivate lazy var imageView = Factory.ImageView.make(fromType: .symbol(image: Factory.Image.make(fromType: .symbol(systemImageName: "exclamationmark.bubble")))) // TODO: check size
  fileprivate lazy var titleLabel = Factory.Label.make(fromType: .title(text: nil, alignment: .center, numberOfLines: 0))
  fileprivate lazy var descriptionLabel = Factory.Label.make(fromType: .subtitle(text: nil, alignment: .center, numberOfLines: 0))
  
  fileprivate lazy var refreshButton = Factory.Button.make(fromType: .standard(title: R.string.localizable.reload(), height: Constants.Dimensions.InteractableElement.height))
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  let viewModel: ViewModel
  
  // MARK: - Initialization
  
  required init(dependencies: ViewModel.Dependencies) {
    viewModel = WeatherListErrorViewModel(dependencies: dependencies)
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
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    viewModel.viewWillDisappear()
  }
}

// MARK: - ViewModel Bindings

extension WeatherListErrorViewController {
  
  func setupBindings() {
    viewModel.observeEvents()
    bindContentFromViewModel(viewModel)
    bindUserInputToViewModel(viewModel)
  }
  
  func bindContentFromViewModel(_ viewModel: ViewModel) {
     viewModel
      .isRefreshingDriver
      .drive(onNext: { [unowned refreshButton] isRefreshing in
        refreshButton.setIsRefreshing(isRefreshing)
      })
      .disposed(by: disposeBag)
    
    viewModel
      .errorTypeDriver
      .drive { [unowned self] listErrorType in
        titleLabel.text = listErrorType.title
        descriptionLabel.text = listErrorType.message
        refreshButton.isHidden = listErrorType != .noData
      }
      .disposed(by: disposeBag)

  }
  
  func bindUserInputToViewModel(_ viewModel: ViewModel) {
    refreshButton.rx
      .tap
      .bind(to: viewModel.onDidTapRefreshButtonSubject)
      .disposed(by: disposeBag)
  }
}

// MARK: - Setup

private extension WeatherListErrorViewController {
  
  func setupUiComponents() {
    // compose stackviews
    textStackView.addArrangedSubview(titleLabel)
    textStackView.addArrangedSubview(descriptionLabel)
    
    mainContentStackView.addArrangedSubview(imageView)
    mainContentStackView.addArrangedSubview(textStackView)
    mainContentStackView.addArrangedSubview(refreshButton, constraints: [
      refreshButton.heightAnchor.constraint(equalToConstant: Constants.Dimensions.InteractableElement.height),
      refreshButton.widthAnchor.constraint(equalToConstant: view.frame.size.width - ContentInsets.leading(from: .large) - ContentInsets.trailing(from: .large))
    ])
    
    // compose final view
    view.addSubview(mainContentStackView, constraints: [
      mainContentStackView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: ContentInsets.top(from: .large)),
      mainContentStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -ContentInsets.bottom(from: .large) - (tabBarController?.tabBar.frame.size.height ?? 0)),
      mainContentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ContentInsets.leading(from: .large)),
      mainContentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -ContentInsets.trailing(from: .large)),
      mainContentStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -(tabBarController?.tabBar.frame.size.height ?? 0))
    ])
  }
  
  func setupUiAppearance() {
    title = R.string.localizable.tab_weatherList()
    
    tabBarController?.tabBar.isTranslucent = true
    navigationController?.navigationBar.isTranslucent = true
    navigationController?.view.backgroundColor = Constants.Theme.Color.ViewElement.secondaryBackground
    view.backgroundColor = Constants.Theme.Color.ViewElement.secondaryBackground
  }
}
