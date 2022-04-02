//
//  WeatherStationCurrentInformationHeaderCell.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 13.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxSwift

// MARK: - Definitions

private extension WeatherStationMeteorologyDetailsHeaderCell {
  struct Definitions {
    static let weatherConditionSymbolWidthHeight: CGFloat = 80
  }
}

// MARK: - Class Definition

final class WeatherStationMeteorologyDetailsHeaderCell: UITableViewCell, BaseCell {
  
  typealias CellViewModel = WeatherStationMeteorologyDetailsHeaderCellViewModel
  private typealias CellContentInsets = Constants.Dimensions.Spacing.ContentInsets
  private typealias CellInterelementSpacing = Constants.Dimensions.Spacing.InterElementSpacing
  
  // MARK: - UIComponents
  
  private lazy var weatherConditionSymbolImageView = Factory.ImageView.make(fromType: .weatherConditionSymbol)
  
  private lazy var weatherConditionTitleLabel = Factory.Label.make(fromType: .headline(textColor: Constants.Theme.Color.ViewElement.WeatherInformation.colorBackgroundPrimaryTitle))
  private lazy var currentTemperatureLabel = Factory.Label.make(fromType: .headline(alignment: .right, textColor: Constants.Theme.Color.ViewElement.WeatherInformation.colorBackgroundPrimaryTitle))
  
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
    guard let cellViewModel = cellViewModel as? WeatherStationMeteorologyDetailsHeaderCellViewModel else {
      return
    }
    self.cellViewModel = cellViewModel
    cellViewModel.observeEvents()
    bindContentFromViewModel(cellViewModel)
    bindUserInputToViewModel(cellViewModel)
  }
}

// MARK: - ViewModel Bindings

extension WeatherStationMeteorologyDetailsHeaderCell {
  
  func bindContentFromViewModel(_ cellViewModel: CellViewModel) {
    cellViewModel.cellModelDriver
      .drive(onNext: { [setContent] in setContent($0) })
      .disposed(by: disposeBag)
  }
}

// MARK: - Cell Composition

private extension WeatherStationMeteorologyDetailsHeaderCell {
  
  func setContent(for cellModel: WeatherStationMeteorologyDetailsHeaderCellModel) {
    contentView.backgroundColor = cellModel.backgroundColor
  
    weatherConditionSymbolImageView.image = cellModel.weatherConditionSymbolImage
    weatherConditionTitleLabel.text = cellModel.weatherConditionTitle
    currentTemperatureLabel.text = cellModel.currentTemperature
  }
  
  func layoutUserInterface() {
    separatorInset = UIEdgeInsets(
      top: 0,
      left: contentView.frame.size.width,
      bottom: 0,
      right: contentView.frame.size.width
    )
    
    contentView.addSubview(weatherConditionSymbolImageView, constraints: [
      weatherConditionSymbolImageView.heightAnchor.constraint(equalToConstant: Definitions.weatherConditionSymbolWidthHeight),
      weatherConditionSymbolImageView.widthAnchor.constraint(equalToConstant: Definitions.weatherConditionSymbolWidthHeight),
      weatherConditionSymbolImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      weatherConditionSymbolImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CellContentInsets.top(from: .medium)),
      weatherConditionSymbolImageView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: CellContentInsets.leading(from: .medium)),
      weatherConditionSymbolImageView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: CellContentInsets.trailing(from: .medium))
    ])
    
    contentView.addSubview(weatherConditionTitleLabel, constraints: [
      weatherConditionTitleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.ContentElement.height),
      weatherConditionTitleLabel.topAnchor.constraint(equalTo: weatherConditionSymbolImageView.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .extraLarge)),
      weatherConditionTitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .large)),
      weatherConditionTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CellContentInsets.leading(from: .medium))
    ])
    
    contentView.addSubview(currentTemperatureLabel, constraints: [
      currentTemperatureLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.ContentElement.height),
      currentTemperatureLabel.widthAnchor.constraint(equalTo: weatherConditionTitleLabel.widthAnchor),
      currentTemperatureLabel.topAnchor.constraint(equalTo: weatherConditionSymbolImageView.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .extraLarge)),
      currentTemperatureLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .large)),
      currentTemperatureLabel.leadingAnchor.constraint(equalTo: weatherConditionTitleLabel.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .small)),
      currentTemperatureLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CellContentInsets.trailing(from: .medium)),
      currentTemperatureLabel.firstBaselineAnchor.constraint(equalTo: weatherConditionTitleLabel.firstBaselineAnchor)
    ])
  }
  
  func setupAppearance() {
    selectionStyle = .none
    backgroundColor = .clear
  }
}
