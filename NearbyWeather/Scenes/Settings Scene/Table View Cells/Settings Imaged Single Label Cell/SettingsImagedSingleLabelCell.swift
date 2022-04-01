//
//  SettingsImagedSingleLabelCell.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 06.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxSwift

// MARK: - Definitions

private extension SettingsImagedSingleLabelCell {
  struct Definitions {}
}

// MARK: - Class Definition

final class SettingsImagedSingleLabelCell: UITableViewCell, BaseCell {
  
  typealias CellViewModel = SettingsImagedSingleLabelCellViewModel
  private typealias CellContentInsets = Constants.Dimensions.Spacing.ContentInsets
  private typealias CellInterelementSpacing = Constants.Dimensions.Spacing.InterElementSpacing
  
  // MARK: - UIComponents
  
  private lazy var leadingImageBackgroundColorView = Factory.View.make(fromType: .cellPrefix)
  private lazy var leadingImageView = Factory.ImageView.make(fromType: .cellPrefix)
  private lazy var contentLabel = Factory.Label.make(fromType: .body(textColor: Constants.Theme.Color.ViewElement.Label.titleDark))
  
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
    guard let cellViewModel = cellViewModel as? SettingsImagedSingleLabelCellViewModel else {
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

extension SettingsImagedSingleLabelCell {
  
  func bindContentFromViewModel(_ cellViewModel: CellViewModel) {
    cellViewModel.cellModelDriver
      .drive(onNext: { [setContent] in setContent($0) })
      .disposed(by: disposeBag)
  }
}

// MARK: - Cell Composition

private extension SettingsImagedSingleLabelCell {
  
  func setContent(for cellModel: SettingsImagedSingleLabelCellModel) {
    leadingImageBackgroundColorView.backgroundColor = cellModel.symbolImageBackgroundColor
    leadingImageView.image = Factory.Image.make(fromType: .cellSymbol(systemImageName: cellModel.symbolImageName))
    contentLabel.text = cellModel.labelText
    
    selectionStyle = (cellModel.isSelectable ?? false) ? .default : .none
    accessoryType = (cellModel.isDisclosable ?? false) ? .disclosureIndicator : .none
  }
  
  func layoutUserInterface() {
    separatorInset = UIEdgeInsets(
      top: 0,
      left: CellContentInsets.leading(from: .extraLarge)
        + Constants.Dimensions.TableCellImage.backgroundWidth
        + CellInterelementSpacing.xDistance(from: .medium),
      bottom: 0,
      right: 0
    )
    
    contentView.addSubview(leadingImageBackgroundColorView, constraints: [
      leadingImageBackgroundColorView.heightAnchor.constraint(equalToConstant: Constants.Dimensions.TableCellImage.backgroundHeight),
      leadingImageBackgroundColorView.widthAnchor.constraint(equalToConstant: Constants.Dimensions.TableCellImage.backgroundWidth),
      leadingImageBackgroundColorView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: CellContentInsets.top(from: .medium)),
      leadingImageBackgroundColorView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .medium)),
      leadingImageBackgroundColorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CellContentInsets.leading(from: .extraLarge)),
      leadingImageBackgroundColorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ])
    
    leadingImageBackgroundColorView.addSubview(leadingImageView, constraints: [
      leadingImageView.heightAnchor.constraint(equalToConstant: Constants.Dimensions.TableCellImage.foregroundHeight),
      leadingImageView.widthAnchor.constraint(equalToConstant: Constants.Dimensions.TableCellImage.foregroundWidth),
      leadingImageView.centerYAnchor.constraint(equalTo: leadingImageBackgroundColorView.centerYAnchor),
      leadingImageView.centerXAnchor.constraint(equalTo: leadingImageBackgroundColorView.centerXAnchor)
    ])
    
    contentView.addSubview(contentLabel, constraints: [
      contentLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.ContentElement.height),
      contentLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CellContentInsets.top(from: .medium)),
      contentLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .medium)),
      contentLabel.leadingAnchor.constraint(equalTo: leadingImageBackgroundColorView.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .medium)),
      contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CellContentInsets.trailing(from: .large)),
      contentLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ])
  }
  
  func setupAppearance() {
    backgroundColor = Constants.Theme.Color.ViewElement.primaryBackground
    contentView.backgroundColor = .clear
  }
}
