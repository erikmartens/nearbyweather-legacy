//
//  SettingsSingleLabelDualButtonCell.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxSwift

// MARK: - Definitions

private extension SettingsSingleLabelDualButtonCell {
  struct Definitions {
    static let cellButtonHeight: CGFloat = 24
  }
}

// MARK: - Class Definition

final class SettingsSingleLabelDualButtonCell: UITableViewCell, BaseCell {
  
  typealias CellViewModel = SettingsSingleLabelDualButtonCellViewModel
  private typealias CellContentInsets = Constants.Dimensions.Spacing.ContentInsets
  private typealias CellInterelementSpacing = Constants.Dimensions.Spacing.InterElementSpacing
  
  // MARK: - UIComponents
  
  private lazy var leadingImageView = Factory.ImageView.make(fromType: .cellPrefix)
  private lazy var contentLabel = Factory.Label.make(fromType: .body())
  private lazy var lhsButton = Factory.Button.make(fromType: .standard(height: Definitions.cellButtonHeight))
  private lazy var rhsButton = Factory.Button.make(fromType: .standard(height: Definitions.cellButtonHeight))
  
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
    guard let cellViewModel = cellViewModel as? SettingsSingleLabelDualButtonCellViewModel else {
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

extension SettingsSingleLabelDualButtonCell {
  
  func bindContentFromViewModel(_ cellViewModel: CellViewModel) {
    cellViewModel.cellModelDriver
      .drive(onNext: { [setContent] in setContent($0) })
      .disposed(by: disposeBag)
  }
  
  func bindUserInputToViewModel(_ cellViewModel: CellViewModel) {
    lhsButton.rx
      .controlEvent(.touchUpInside)
      .bind(to: cellViewModel.didTapLhsButtonSubject)
      .disposed(by: disposeBag)
    
    rhsButton.rx
      .controlEvent(.touchUpInside)
      .bind(to: cellViewModel.didTapRhsButtonSubject)
      .disposed(by: disposeBag)
  }
}

// MARK: - Cell Composition

private extension SettingsSingleLabelDualButtonCell {
  
  func setContent(for cellModel: SettingsSingleLabelDualButtonCellModel) {
    contentLabel.text = cellModel.contentLabelText
    lhsButton.setTitle(cellModel.lhsButtonTitle, for: UIControl.State())
    rhsButton.setTitle(cellModel.rhsButtonTitle, for: UIControl.State())
  }
  
  func layoutUserInterface() {
    contentView.addSubview(contentLabel, constraints: [
      contentLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.ContentElement.height),
      contentLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CellContentInsets.top(from: .medium)),
      contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CellContentInsets.leading(from: .large)),
      contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CellContentInsets.trailing(from: .large))
    ])
    
    contentView.addSubview(lhsButton, constraints: [
      lhsButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Definitions.cellButtonHeight),
      lhsButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .large)),
      lhsButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .medium)),
      lhsButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CellContentInsets.leading(from: .large))
    ])
    
    contentView.addSubview(rhsButton, constraints: [
      rhsButton.centerYAnchor.constraint(equalTo: lhsButton.centerYAnchor),
      rhsButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Definitions.cellButtonHeight),
      rhsButton.heightAnchor.constraint(greaterThanOrEqualTo: lhsButton.heightAnchor),
      rhsButton.widthAnchor.constraint(equalTo: lhsButton.widthAnchor),
      rhsButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .large)),
      rhsButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .medium)),
      rhsButton.leadingAnchor.constraint(equalTo: lhsButton.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .large)),
      rhsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CellContentInsets.trailing(from: .large))
    ])
  }
  
  func setupAppearance() {
    backgroundColor = Constants.Theme.Color.ViewElement.primaryBackground
    contentView.backgroundColor = .clear
    
    selectionStyle = .none
    accessoryType = .none
  }
}
