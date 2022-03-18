//
//  SettingsImagedSingleLabelToggleCell.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 06.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxSwift

// MARK: - Definitions

private extension SettingsImagedSingleLabelToggleCell {
  struct Definitions {}
}

// MARK: - Class Definition

final class SettingsImagedSingleLabelToggleCell: UITableViewCell, BaseCell {
  
  typealias CellViewModel = SettingsImagedSingleLabelToggleCellViewModel
  private typealias CellContentInsets = Constants.Dimensions.Spacing.ContentInsets
  private typealias CellInterelementSpacing = Constants.Dimensions.Spacing.InterElementSpacing
  
  // MARK: - UIComponents
  
  private lazy var leadingImageView = Factory.ImageView.make(fromType: .cellPrefix)
  private lazy var contentLabel = Factory.Label.make(fromType: .body(textColor: Constants.Theme.Color.ViewElement.Label.titleDark))
  private lazy var toggleSwitch = UISwitch()
  
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
    guard let cellViewModel = cellViewModel as? SettingsImagedSingleLabelToggleCellViewModel else {
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

extension SettingsImagedSingleLabelToggleCell {
  
  func bindContentFromViewModel(_ cellViewModel: CellViewModel) {
    cellViewModel.cellModelDriver
      .drive(onNext: { [setContent] in setContent($0) })
      .disposed(by: disposeBag)
  }
  
  func bindUserInputToViewModel(_ cellViewModel: CellViewModel) {
    toggleSwitch.rx
      .controlEvent(.valueChanged)
      .withLatestFrom(toggleSwitch.rx.value)
      .bind(to: cellViewModel.onDidFlipToggleSwitchSubject)
      .disposed(by: disposeBag)
  }
}

// MARK: - Cell Composition

private extension SettingsImagedSingleLabelToggleCell {
  
  func setContent(for cellModel: SettingsImagedSingleLabelToggleCellModel) {
    leadingImageView.backgroundColor = cellModel.symbolImageBackgroundColor
    leadingImageView.image = cellModel.symbolImage
    contentLabel.text = cellModel.labelText
    toggleSwitch.isOn = cellModel.isToggleOn ?? false
  }
  
  func layoutUserInterface() {
    separatorInset = UIEdgeInsets(
      top: 0,
      left: CellContentInsets.leading(from: .extraLarge)
        + Constants.Dimensions.TableCellImage.width
        + Constants.Dimensions.Spacing.InterElementSpacing.xDistance(from: .medium),
      bottom: 0,
      right: 0
    )
    
    contentView.addSubview(leadingImageView, constraints: [
      leadingImageView.heightAnchor.constraint(equalToConstant: Constants.Dimensions.TableCellImage.height),
      leadingImageView.widthAnchor.constraint(equalToConstant: Constants.Dimensions.TableCellImage.width),
      leadingImageView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: CellContentInsets.top(from: .medium)),
      leadingImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .medium)),
      leadingImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CellContentInsets.leading(from: .extraLarge)),
      leadingImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ])
    
    contentView.addSubview(contentLabel, constraints: [
      contentLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.ContentElement.height),
      contentLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CellContentInsets.top(from: .medium)),
      contentLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .medium)),
      contentLabel.leadingAnchor.constraint(equalTo: leadingImageView.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .medium)),
      contentLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ])
    
    contentView.addSubview(toggleSwitch, constraints: [
      toggleSwitch.heightAnchor.constraint(equalToConstant: toggleSwitch.bounds.height),
      toggleSwitch.widthAnchor.constraint(equalToConstant: toggleSwitch.bounds.width),
      toggleSwitch.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: CellContentInsets.top(from: .large)),
      toggleSwitch.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .large)),
      toggleSwitch.leadingAnchor.constraint(equalTo: contentLabel.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .small)),
      toggleSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CellContentInsets.trailing(from: .large)),
      toggleSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ])
  }
  
  func setupAppearance() {
    backgroundColor = Constants.Theme.Color.ViewElement.primaryBackground
    contentView.backgroundColor = .clear
    selectionStyle = .none
    accessoryType = .none
  }
}
