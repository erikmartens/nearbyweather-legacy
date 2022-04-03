//
//  WeatherStationMeteorologyDetailsSymbolCell.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 02.04.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxSwift

// MARK: - Definitions

private extension WeatherStationMeteorologyDetailsSymbolCell {
  struct Definitions {}
}

// MARK: - Class Definition

final class WeatherStationMeteorologyDetailsSymbolCell: UITableViewCell, BaseCell {
  
  typealias CellViewModel = WeatherStationMeteorologyDetailsSymbolCellViewModel
  private typealias CellContentInsets = Constants.Dimensions.Spacing.ContentInsets
  private typealias CellInterelementSpacing = Constants.Dimensions.Spacing.InterElementSpacing
  
  // MARK: - UIComponents
  
  private lazy var leadingImageView = Factory.ImageView.make(fromType: .cellPrefix)
  private lazy var contentLabel = Factory.Label.make(fromType: .body(textColor: Constants.Theme.Color.ViewElement.Label.titleDark))
  private lazy var descriptionLabel = Factory.Label.make(fromType: .subtitle(alignment: .right, numberOfLines: 1, textColor: Constants.Theme.Color.ViewElement.Label.subtitleDark))
  
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
    guard let cellViewModel = cellViewModel as? WeatherStationMeteorologyDetailsSymbolCellViewModel else {
      return
    }
    
    self.cellViewModel = cellViewModel
    cellViewModel.observeEvents()
    bindContentFromViewModel(cellViewModel)
    bindUserInputToViewModel(cellViewModel)
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    leadingImageView.transform = CGAffineTransform(rotationAngle: 0)
    disposeBag = DisposeBag()
  }
}

// MARK: - ViewModel Bindings

extension WeatherStationMeteorologyDetailsSymbolCell {
  
  func bindContentFromViewModel(_ cellViewModel: CellViewModel) {
    cellViewModel.cellModelDriver
      .drive(onNext: { [setContent] in setContent($0) })
      .disposed(by: disposeBag)
  }
}

// MARK: - Cell Composition

private extension WeatherStationMeteorologyDetailsSymbolCell {
  
  func setContent(for cellModel: WeatherStationMeteorologyDetailsSymbolCellModel) {
    leadingImageView.image = Factory.Image.make(fromType: .cellSymbol(systemImageName: cellModel.symbolImageName))
    if let symbolRotationAngle = cellModel.symbolImageRotationAngle {
      leadingImageView.transform = CGAffineTransform(rotationAngle: symbolRotationAngle)
    }
    contentLabel.text = cellModel.contentLabelText
    descriptionLabel.text = cellModel.descriptionLabelText
    
    selectionStyle = (cellModel.isSelectable ?? false) ? .default : .none
    accessoryType = (cellModel.isDisclosable ?? false) ? .disclosureIndicator : .none
  }
  
  func layoutUserInterface() {
    separatorInset = UIEdgeInsets(
      top: 0,
      left: CellContentInsets.leading(from: .large)
        + Constants.Dimensions.TableCellImage.foregroundWidth
        + CellInterelementSpacing.xDistance(from: .medium),
      bottom: 0,
      right: 0
    )
    
    contentView.addSubview(leadingImageView, constraints: [
      leadingImageView.heightAnchor.constraint(equalToConstant: Constants.Dimensions.TableCellImage.foregroundHeight),
      leadingImageView.widthAnchor.constraint(equalToConstant: Constants.Dimensions.TableCellImage.foregroundHeight),
      leadingImageView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: CellContentInsets.top(from: .medium)),
      leadingImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .medium)),
      leadingImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CellContentInsets.leading(from: .large)),
      leadingImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ])
    
    contentView.addSubview(contentLabel, constraints: [
      contentLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.ContentElement.height),
      contentLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CellContentInsets.top(from: .medium)),
      contentLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .medium)),
      contentLabel.leadingAnchor.constraint(equalTo: leadingImageView.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .medium)),
      contentLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ])
    
    contentView.addSubview(descriptionLabel, constraints: [
      descriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.ContentElement.height),
      descriptionLabel.heightAnchor.constraint(equalTo: contentLabel.heightAnchor),
      descriptionLabel.widthAnchor.constraint(equalTo: contentLabel.widthAnchor, multiplier: 2/3),
      descriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CellContentInsets.top(from: .medium)),
      descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .medium)),
      descriptionLabel.leadingAnchor.constraint(equalTo: contentLabel.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .large)),
      descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CellContentInsets.trailing(from: .large)),
      descriptionLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ])
  }
  
  func setupAppearance() {
    backgroundColor = Constants.Theme.Color.ViewElement.primaryBackground
    contentView.backgroundColor = .clear
  }
}

