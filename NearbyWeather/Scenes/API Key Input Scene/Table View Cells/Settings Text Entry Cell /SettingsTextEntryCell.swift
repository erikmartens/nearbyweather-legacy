//
//  SettingsTextEntryCell.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxSwift

// MARK: - Definitions

private extension SettingsTextEntryCell {
  struct Definitions {}
}

// MARK: - Class Definition

final class SettingsTextEntryCell: UITableViewCell, BaseCell {
  
  typealias CellViewModel = SettingsTextEntryCellViewModel
  private typealias CellContentInsets = Constants.Dimensions.Spacing.ContentInsets
  private typealias CellInterelementSpacing = Constants.Dimensions.Spacing.InterElementSpacing
  
  // MARK: - UIComponents
  
  private(set) lazy var textEntryTextField = Factory.TextField.make(fromType: .counter(count: Constants.Values.ApiKey.kOpenWeatherMapApiKeyLength, cornerRadiusWeight: .medium))
  
  // MARK: - Assets
  
  private var disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  var cellViewModel: CellViewModel?
  
  // MARK: - Initialization
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    layoutUserInterface()
    setupAppearance()
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
  
  // MARK: - Cell Life Cycle
  
  func configure(with cellViewModel: BaseCellViewModelProtocol?) {
    guard let cellViewModel = cellViewModel as? SettingsTextEntryCellViewModel else {
      return
    }
    
    self.cellViewModel = cellViewModel
    cellViewModel.observeEvents()
    bindContentFromViewModel(cellViewModel)
    bindUserInputToViewModel(cellViewModel)
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    disposeBag = DisposeBag()
  }
}

// MARK: - ViewModel Bindings

extension SettingsTextEntryCell {
  
  func bindContentFromViewModel(_ cellViewModel: CellViewModel) {
    cellViewModel.cellModelDriver
      .drive(onNext: { [setContent] in setContent($0) })
      .disposed(by: disposeBag)
  }
  
  func bindUserInputToViewModel(_ cellViewModel: SettingsTextEntryCellViewModel) {
    textEntryTextField.rx
      .value
      .bind(to: cellViewModel.textFieldTextSubject)
      .disposed(by: disposeBag)
  }
}

// MARK: - Cell Composition

private extension SettingsTextEntryCell {
  
  func setContent(for cellModel: SettingsTextEntryCellModel) {
    textEntryTextField.placeholder = cellModel.textFieldPlaceholderText
    textEntryTextField.text = cellModel.textFieldText
  }
  
  func layoutUserInterface() {
    contentView.addSubview(textEntryTextField, constraints: [
      textEntryTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.ContentElement.height),
      textEntryTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CellContentInsets.top(from: .medium)),
      textEntryTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .medium)),
      textEntryTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CellContentInsets.leading(from: .large)),
      textEntryTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CellContentInsets.trailing(from: .large)),
      textEntryTextField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ])
  }
  
  func setupAppearance() {
    backgroundColor = Constants.Theme.Color.ViewElement.primaryBackground
    contentView.backgroundColor = .clear
    
    selectionStyle = .none
    accessoryType = .none
  }
}
