//
//  SettingsImagedDualLabelSubtitleCell.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 20.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxSwift

// MARK: - Definitions

private extension SettingsImagedDualLabelSubtitleCell {
  struct Definitions {
    static let labelHeight: CGFloat = 20
  }
}

// MARK: - Class Definition

final class SettingsImagedDualLabelSubtitleCell: UITableViewCell, BaseCell {
  
  typealias CellViewModel = SettingsImagedDualLabelSubtitleCellViewModel
  private typealias CellContentInsets = Constants.Dimensions.Spacing.ContentInsets
  private typealias CellInterelementSpacing = Constants.Dimensions.Spacing.InterElementSpacing
  
  // MARK: - UIComponents
  
  private lazy var leadingImageView = Factory.ImageView.make(fromType: .cellPrefix)
  private lazy var contentLabel = Factory.Label.make(fromType: .body(textColor: Constants.Theme.Color.ViewElement.Label.titleDark))
  private lazy var descriptionLabel = Factory.Label.make(fromType: .subtitle(numberOfLines: 1, textColor: Constants.Theme.Color.ViewElement.Label.subtitleDark))
  
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
    guard let cellViewModel = cellViewModel as? SettingsImagedDualLabelSubtitleCellViewModel else {
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

extension SettingsImagedDualLabelSubtitleCell {
  
  func bindContentFromViewModel(_ cellViewModel: CellViewModel) {
    cellViewModel.cellModelDriver
      .drive(onNext: { [setContent] in setContent($0) })
      .disposed(by: disposeBag)
  }
}

// MARK: - Cell Composition

private extension SettingsImagedDualLabelSubtitleCell {
  
  func setContent(for cellModel: SettingsImagedDualLabelSubtitleCellModel) {
    leadingImageView.backgroundColor = cellModel.symbolImageBackgroundColor
    leadingImageView.image = cellModel.symbolImage
    contentLabel.text = cellModel.contentLabelText
    descriptionLabel.text = cellModel.descriptionLabelText
    
    selectionStyle = (cellModel.isSelectable ?? false) ? .default : .none
    accessoryType = (cellModel.isDisclosable ?? false) ? .disclosureIndicator : .none
  }
  
  func layoutUserInterface() {
    separatorInset = UIEdgeInsets(
      top: 0,
      left: CellContentInsets.leading(from: .extraLarge)
        + Constants.Dimensions.TableCellImage.width
        + CellInterelementSpacing.xDistance(from: .medium),
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
      contentLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Definitions.labelHeight),
      contentLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CellContentInsets.top(from: .medium)),
      contentLabel.leadingAnchor.constraint(equalTo: leadingImageView.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .medium)),
      contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CellContentInsets.trailing(from: .large))
    ])
    
    contentView.addSubview(descriptionLabel, constraints: [
      descriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Definitions.labelHeight),
      descriptionLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .small)),
      descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .medium)),
      descriptionLabel.leadingAnchor.constraint(equalTo: leadingImageView.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .medium)),
      descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CellContentInsets.trailing(from: .large))
    ])
  }
  
  func setupAppearance() {
    backgroundColor = Constants.Theme.Color.ViewElement.primaryBackground
    contentView.backgroundColor = .clear
  }
}
