//
//  WeatherStationCurrentInformationWindCell.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 15.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxSwift

// MARK: - Definitions

private extension WeatherStationMeteorologyDetailsWindCell {
  struct Definitions {
    static let symbolWidth: CGFloat = 20
  }
}

// MARK: - Class Definition

final class WeatherStationMeteorologyDetailsWindCell: UITableViewCell, BaseCell {
  
  typealias CellViewModel = WeatherStationMeteorologyDetailsWindCellViewModel
  private typealias CellContentInsets = Constants.Dimensions.Spacing.ContentInsets
  private typealias CellInterelementSpacing = Constants.Dimensions.Spacing.InterElementSpacing
  
  // MARK: - UIComponents
  
  private lazy var windSpeedSymbolImageView = Factory.ImageView.make(fromType: .symbol(systemImageName: "wind"))
  private lazy var windSpeedDescriptionLabel = Factory.Label.make(fromType: .body(text: R.string.localizable.windspeed(), textColor: Constants.Theme.Color.ViewElement.Label.titleDark))
  private lazy var windSpeedLabel = Factory.Label.make(fromType: .subtitle(alignment: .right))
  
  private lazy var windDirectionSymbolImageView = Factory.ImageView.make(fromType: .symbol(systemImageName: "arrow.up.circle"))
  private lazy var windDirectionDescriptionLabel = Factory.Label.make(fromType: .body(text: R.string.localizable.wind_direction(), textColor: Constants.Theme.Color.ViewElement.Label.titleDark))
  private lazy var windDirectionLabel = Factory.Label.make(fromType: .subtitle(alignment: .right))
  
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
  
  // MARK: - Cell Life Cycle
  
  func configure(with cellViewModel: BaseCellViewModelProtocol?) {
    guard let cellViewModel = cellViewModel as? WeatherStationMeteorologyDetailsWindCellViewModel else {
      return
    }
    self.cellViewModel = cellViewModel
    cellViewModel.observeEvents()
    bindContentFromViewModel(cellViewModel)
    bindUserInputToViewModel(cellViewModel)
  }
}

// MARK: - ViewModel Bindings

extension WeatherStationMeteorologyDetailsWindCell {
  
  func bindContentFromViewModel(_ cellViewModel: CellViewModel) {
    cellViewModel.cellModelDriver
      .drive(onNext: { [setContent] in setContent($0) })
      .disposed(by: disposeBag)
  }
}

// MARK: - Cell Composition

private extension WeatherStationMeteorologyDetailsWindCell {
  
  func setContent(for cellModel: WeatherStationMeteorologyDetailsWindCellModel) {
    windSpeedLabel.text = cellModel.windSpeedString
    if let windDirectionRotationAngle = cellModel.windDirectionRotationAngle {
      windDirectionSymbolImageView.transform = CGAffineTransform(rotationAngle: windDirectionRotationAngle)
    }
    windDirectionLabel.text = cellModel.windDirectionString
  }
  
  func layoutUserInterface() {
    // line 1
    contentView.addSubview(windSpeedSymbolImageView, constraints: [
      windSpeedSymbolImageView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: CellContentInsets.top(from: .medium)),
      windSpeedSymbolImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CellContentInsets.leading(from: .medium)),
      windSpeedSymbolImageView.widthAnchor.constraint(equalToConstant: Definitions.symbolWidth),
      windSpeedSymbolImageView.heightAnchor.constraint(equalTo: windSpeedSymbolImageView.widthAnchor)
    ])
    
    contentView.addSubview(windSpeedDescriptionLabel, constraints: [
      windSpeedDescriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CellContentInsets.top(from: .medium)),
      windSpeedDescriptionLabel.leadingAnchor.constraint(equalTo: windSpeedSymbolImageView.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .small)),
      windSpeedDescriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.ContentElement.height),
      windSpeedDescriptionLabel.centerYAnchor.constraint(equalTo: windSpeedSymbolImageView.centerYAnchor)
    ])
    
    contentView.addSubview(windSpeedLabel, constraints: [
      windSpeedLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CellContentInsets.top(from: .medium)),
      windSpeedLabel.leadingAnchor.constraint(equalTo: windSpeedDescriptionLabel.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .small)),
      windSpeedLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CellContentInsets.trailing(from: .medium)),
      windSpeedLabel.widthAnchor.constraint(equalTo: windSpeedDescriptionLabel.widthAnchor, multiplier: 4/5),
      windSpeedLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.ContentElement.height),
      windSpeedLabel.centerYAnchor.constraint(equalTo: windSpeedDescriptionLabel.centerYAnchor),
      windSpeedLabel.centerYAnchor.constraint(equalTo: windSpeedSymbolImageView.centerYAnchor)
    ])
    
    // line 2
    contentView.addSubview(windDirectionSymbolImageView, constraints: [
      windDirectionSymbolImageView.topAnchor.constraint(greaterThanOrEqualTo: windSpeedSymbolImageView.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .medium)),
      windDirectionSymbolImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CellContentInsets.leading(from: .medium)),
      windDirectionSymbolImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .medium)),
      windDirectionSymbolImageView.widthAnchor.constraint(equalToConstant: Definitions.symbolWidth),
      windDirectionSymbolImageView.heightAnchor.constraint(equalTo: windDirectionSymbolImageView.widthAnchor)
    ])
    
    contentView.addSubview(windDirectionDescriptionLabel, constraints: [
      windDirectionDescriptionLabel.topAnchor.constraint(equalTo: windSpeedDescriptionLabel.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .medium)),
      windDirectionDescriptionLabel.leadingAnchor.constraint(equalTo: windDirectionSymbolImageView.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .small)),
      windDirectionDescriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .medium)),
      windDirectionDescriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.ContentElement.height),
      windDirectionDescriptionLabel.centerYAnchor.constraint(equalTo: windDirectionSymbolImageView.centerYAnchor)
    ])
    
    contentView.addSubview(windDirectionLabel, constraints: [
      windDirectionLabel.topAnchor.constraint(equalTo: windSpeedLabel.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .medium)),
      windDirectionLabel.leadingAnchor.constraint(equalTo: windDirectionDescriptionLabel.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .small)),
      windDirectionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CellContentInsets.trailing(from: .medium)),
      windDirectionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .medium)),
      windDirectionLabel.widthAnchor.constraint(equalTo: windDirectionDescriptionLabel.widthAnchor, multiplier: 4/5),
      windDirectionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.ContentElement.height),
      windDirectionLabel.centerYAnchor.constraint(equalTo: windDirectionDescriptionLabel.centerYAnchor),
      windDirectionLabel.centerYAnchor.constraint(equalTo: windDirectionSymbolImageView.centerYAnchor)
    ])
  }
  
  func setupAppearance() {
    selectionStyle = .none
    backgroundColor = .clear
    contentView.backgroundColor = Constants.Theme.Color.ViewElement.primaryBackground
  }
}
