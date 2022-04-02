//
//  SettingsDualLabelSubtitleCell.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxSwift

// MARK: - Definitions

private extension SettingsDualLabelSubtitleCell {
  struct Definitions {}
}

// MARK: - Class Definition

final class SettingsDualLabelSubtitleCell: UITableViewCell, BaseCell {
  
  typealias CellViewModel = SettingsDualLabelSubtitleCellViewModel
  private typealias CellContentInsets = Constants.Dimensions.Spacing.ContentInsets
  private typealias CellInterelementSpacing = Constants.Dimensions.Spacing.InterElementSpacing
  
  // MARK: - UIComponents
  
  private lazy var leadingImageView = Factory.ImageView.make(fromType: .cellPrefix)
  private lazy var contentLabel = Factory.Label.make(fromType: .body(textColor: Constants.Theme.Color.ViewElement.Label.titleDark))
  private lazy var subtitleLabel = Factory.Label.make(fromType: .subtitle())
  
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
    guard let cellViewModel = cellViewModel as? SettingsDualLabelSubtitleCellViewModel else {
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

extension SettingsDualLabelSubtitleCell {
  
  func bindContentFromViewModel(_ cellViewModel: CellViewModel) {
    cellViewModel.cellModelDriver
      .drive(onNext: { [setContent] in setContent($0) })
      .disposed(by: disposeBag)
  }
}

// MARK: - Cell Composition

private extension SettingsDualLabelSubtitleCell {
  
  func setContent(for cellModel: SettingsDualLabelSubtitleCellModel) {
    contentLabel.text = cellModel.contentLabelText
    subtitleLabel.text = cellModel.subtitleLabelText
    
    selectionStyle = (cellModel.isSelectable ?? false) ? .default : .none
    accessoryType = (cellModel.isDisclosable ?? false) ? .disclosureIndicator : .none
  }
  
  func layoutUserInterface() {
    contentView.addSubview(contentLabel, constraints: [
      contentLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.ContentElement.height),
      contentLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CellContentInsets.top(from: .medium)),
      contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CellContentInsets.leading(from: .large)),
      contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CellContentInsets.trailing(from: .large))
    ])
    
    contentView.addSubview(subtitleLabel, constraints: [
      subtitleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.ContentElement.height*(3/4)),
      subtitleLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .medium)),
      subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .medium)),
      subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CellContentInsets.leading(from: .large)),
      subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CellContentInsets.trailing(from: .large))
    ])
  }
  
  func setupAppearance() {
    backgroundColor = Constants.Theme.Color.ViewElement.primaryBackground
    contentView.backgroundColor = .clear
  }
}
