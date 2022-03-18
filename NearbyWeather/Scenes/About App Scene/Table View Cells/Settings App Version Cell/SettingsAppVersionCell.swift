//
//  SettingsAppVersionCell.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxSwift

class SettingsAppVersionCell: UITableViewCell, BaseCell {
  
  typealias CellViewModel = SettingsAppVersionCellViewModel
  private typealias CellContentInsets = Constants.Dimensions.Spacing.ContentInsets
  private typealias CellInterelementSpacing = Constants.Dimensions.Spacing.InterElementSpacing
  
  // MARK: - UIComponents
  
  private lazy var mainImageView = Factory.ImageView.make(fromType: .appIcon)
  private lazy var titleLabel = Factory.Label.make(fromType: .title(alignment: .center))
  private lazy var subtitleLabel = Factory.Label.make(fromType: .subtitle(alignment: .center))
  
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
    guard let cellViewModel = cellViewModel as? SettingsAppVersionCellViewModel else {
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

extension SettingsAppVersionCell {
  
  func bindContentFromViewModel(_ cellViewModel: CellViewModel) {
    cellViewModel.cellModelDriver
      .drive(onNext: { [setContent] in setContent($0) })
      .disposed(by: disposeBag)
  }
}

// MARK: - Cell Composition

private extension SettingsAppVersionCell {
  
  func setContent(for cellModel: SettingsAppVersionCellModel) {
    mainImageView.image = cellModel.appIconImage
    titleLabel.text = cellModel.appNameTitle
    subtitleLabel.text = cellModel.appVersionTitle
  }
  
  func layoutUserInterface() {
    contentView.addSubview(mainImageView, constraints: [
      mainImageView.heightAnchor.constraint(equalToConstant: Constants.Dimensions.AppIconImage.height),
      mainImageView.widthAnchor.constraint(equalToConstant: Constants.Dimensions.AppIconImage.width),
      mainImageView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: CellContentInsets.top(from: .large)),
      mainImageView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: CellContentInsets.leading(from: .large)),
      mainImageView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -CellContentInsets.trailing(from: .large)),
      mainImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
    ])
    
    contentView.addSubview(titleLabel, constraints: [
      titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.ContentElement.height),
      titleLabel.topAnchor.constraint(equalTo: mainImageView.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .medium)),
      titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CellContentInsets.leading(from: .large)),
      titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CellContentInsets.trailing(from: .large))
    ])
    
    contentView.addSubview(subtitleLabel, constraints: [
      subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .medium)),
      subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .large)),
      subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CellContentInsets.leading(from: .large)),
      subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CellContentInsets.trailing(from: .large))
    ])
  }
  
  func setupAppearance() {
    backgroundColor = .clear
    contentView.backgroundColor = .clear
    
    selectionStyle = .none
    accessoryType = .none
  }
}
