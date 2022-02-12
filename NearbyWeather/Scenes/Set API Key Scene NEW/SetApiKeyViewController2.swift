//
//  SetApiKeyViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.02.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxSwift

// MARK: - Definitions

private extension SetApiKeyViewController2 {
  struct Definitions {
    static let apiKeyLength: Int = 32
    static let mainStackViewInterElementYSpacing: CGFloat = 48
  }
}

// MARK: - Class Definition

final class SetApiKeyViewController2: UIViewController, BaseViewController {
  
  typealias ViewModel = SetApiKeyViewModel
  private typealias ContentInsets = Constants.Dimensions.Spacing.ContentInsets
  
  // MARK: - UIComponents
  
  fileprivate lazy var mainContentStackView = Factory.StackView.make(fromType: .vertical(distribution: .equalSpacing, spacingWeight: .custom(value: Definitions.mainStackViewInterElementYSpacing)))
  fileprivate lazy var bubbleView = Factory.View.make(fromType: .standard(cornerRadiusWeight: .medium))
  fileprivate lazy var bubbleContentStackView = Factory.StackView.make(fromType: .vertical(distribution: .equalSpacing, spacingWeight: .large))
  fileprivate lazy var bubbleDescriptionLabel = Factory.Label.make(fromType: .description(text: R.string.localizable.welcome_api_key_description()))
  fileprivate lazy var apiKeyInputTextField = Factory.TextField.make(fromType: .counter(count: Definitions.apiKeyLength, cornerRadiusWeight: .medium))
  fileprivate lazy var buttonStackView = Factory.StackView.make(fromType: .vertical(distribution: .fillProportionally, spacingWeight: .large))
  fileprivate lazy var saveButton = Factory.Button.make(fromType: .standard(title: R.string.localizable.save(), height: Constants.Dimensions.InteractableElement.height))
  fileprivate lazy var instructionsButton = Factory.Button.make(fromType: .plain(title: R.string.localizable.get_api_key_description()))
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  let viewModel: ViewModel
  
  // MARK: - Initialization
  
  required init(dependencies: ViewModel.Dependencies) {
    viewModel = SetApiKeyViewModel(dependencies: dependencies)
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

extension SetApiKeyViewController2 {
  
  func setupBindings() {
    viewModel.observeEvents()
    bindContentFromViewModel(viewModel)
    bindUserInputToViewModel(viewModel)
  }
  
  func bindContentFromViewModel(_ viewModel: ViewModel) {
    viewModel.isSaveButtonActiveDriver
      .drive { [weak self] isEnabled in
        self?.saveButton.isEnabled = isEnabled
      }
      .disposed(by: disposeBag)
  }
  
  func bindUserInputToViewModel(_ viewModel: ViewModel) {
    apiKeyInputTextField.rx
      .text
      .filterNil()
      .bind(to: viewModel.apiInputTextFieldRelay)
      .disposed(by: disposeBag)
    
    saveButton.rx
      .tap
      .bind(to: viewModel.onDidTapSaveButtonSubject)
      .disposed(by: disposeBag)
    
    instructionsButton.rx
      .tap
      .bind(to: viewModel.onDidTapInstructionButtonSubject)
      .disposed(by: disposeBag)
  }
}

// MARK: - Setup

private extension SetApiKeyViewController2 {
  
  func setupUiComponents() {
    // compose stackviews
    bubbleContentStackView.addArrangedSubview(bubbleDescriptionLabel)
    bubbleContentStackView.addArrangedSubview(apiKeyInputTextField, constraints: [
      apiKeyInputTextField.heightAnchor.constraint(equalToConstant: Constants.Dimensions.InteractableElement.height)
    ])
  
    bubbleView.addSubview(bubbleContentStackView, constraints: [
      bubbleContentStackView.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: ContentInsets.top(from: .large)),
      bubbleContentStackView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -ContentInsets.bottom(from: .large)),
      bubbleContentStackView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: ContentInsets.leading(from: .large)),
      bubbleContentStackView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -ContentInsets.trailing(from: .large))
    ])
    
    buttonStackView.addArrangedSubview(saveButton, constraints: [
      saveButton.heightAnchor.constraint(equalToConstant: Constants.Dimensions.InteractableElement.height)
    ])
    buttonStackView.addArrangedSubview(instructionsButton, constraints: [
      instructionsButton.heightAnchor.constraint(equalToConstant: Constants.Dimensions.InteractableElement.height)
    ])
    
    mainContentStackView.addArrangedSubview(bubbleView)
    mainContentStackView.addArrangedSubview(buttonStackView)
    
    // compose final view
    view.addSubview(mainContentStackView, constraints: [
      mainContentStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: ContentInsets.top(from: .large)),
      mainContentStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -ContentInsets.bottom(from: .large)),
      mainContentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ContentInsets.leading(from: .large)),
      mainContentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -ContentInsets.trailing(from: .large))
    ])
  }
  
  func setupUiAppearance() {
    title = R.string.localizable.welcome()
    
    view.backgroundColor = Constants.Theme.Color.ViewElement.primaryBackground
    bubbleView.backgroundColor = Constants.Theme.Color.ViewElement.alert
  }
}

// MARK: - Extensions

extension SetApiKeyViewController2: UINavigationBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        UIBarPosition.topAttached
    }
}
