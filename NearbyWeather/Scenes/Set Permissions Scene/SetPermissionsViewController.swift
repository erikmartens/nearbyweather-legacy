//
//  SetPermissionsViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 13.02.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxSwift

// MARK: - Definitions

private extension SetPermissionsViewController {
  struct Definitions {
    static let mainStackViewInterElementYSpacing: CGFloat = 48
  }
}

// MARK: - Class Definition

final class SetPermissionsViewController: UIViewController, BaseViewController {
  
  typealias ViewModel = SetPermissionsViewModel
  
  private typealias ContentInsets = Constants.Dimensions.Spacing.ContentInsets
  
  // MARK: - UIComponents
  
  fileprivate lazy var mainContentStackView = Factory.StackView.make(fromType: .vertical(distribution: .equalSpacing, spacingWeight: .custom(value: Definitions.mainStackViewInterElementYSpacing)))
  fileprivate lazy var bubbleView = Factory.View.make(fromType: .standard(cornerRadiusWeight: .medium))
  fileprivate lazy var bubbleContentStackView = Factory.StackView.make(fromType: .vertical(distribution: .equalSpacing, spacingWeight: .large))
  fileprivate lazy var bubbleDescriptionLabel = Factory.Label.make(fromType: .subtitle(text: R.string.localizable.configure_location_permissions_description(), textColor: Constants.Theme.Color.ViewElement.Label.titleLight))
  fileprivate lazy var configureButton = Factory.Button.make(fromType: .standard(title: R.string.localizable.configure(), height: Constants.Dimensions.InteractableElement.height))
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  let viewModel: ViewModel
  
  // MARK: - Initialization
  
  required init(dependencies: ViewModel.Dependencies) {
    viewModel = SetPermissionsViewModel(dependencies: dependencies)
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
    
  }
}

// MARK: - ViewModel Bindings

extension SetPermissionsViewController {
  
  func setupBindings() {
    viewModel.observeEvents()
    bindContentFromViewModel(viewModel)
    bindUserInputToViewModel(viewModel)
  }
  
  func bindContentFromViewModel(_ viewModel: ViewModel) {
    
  }
  
  func bindUserInputToViewModel(_ viewModel: ViewModel) {
    configureButton.rx
      .tap
      .bind(to: viewModel.onDidTapConfigureButtonSubject)
      .disposed(by: disposeBag)
  }
}

// MARK: - Setup

private extension SetPermissionsViewController {
  
  func setupUiComponents() {
    // compose stackviews
    bubbleContentStackView.addArrangedSubview(bubbleDescriptionLabel)
  
    bubbleView.addSubview(bubbleContentStackView, constraints: [
      bubbleContentStackView.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: ContentInsets.top(from: .large)),
      bubbleContentStackView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -ContentInsets.bottom(from: .large)),
      bubbleContentStackView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: ContentInsets.leading(from: .large)),
      bubbleContentStackView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -ContentInsets.trailing(from: .large))
    ])
    
    mainContentStackView.addArrangedSubview(bubbleView)
    mainContentStackView.addArrangedSubview(configureButton)
    
    // compose final view
    view.addSubview(mainContentStackView, constraints: [
      mainContentStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: ContentInsets.top(from: .large)),
      mainContentStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -ContentInsets.bottom(from: .large)),
      mainContentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ContentInsets.leading(from: .large)),
      mainContentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -ContentInsets.trailing(from: .large))
    ])
  }
  
  func setupUiAppearance() {
    title = R.string.localizable.location_access()
    
    view.backgroundColor = Constants.Theme.Color.ViewElement.primaryBackground
    bubbleView.backgroundColor = Constants.Theme.Color.ViewElement.alert
  }
}
