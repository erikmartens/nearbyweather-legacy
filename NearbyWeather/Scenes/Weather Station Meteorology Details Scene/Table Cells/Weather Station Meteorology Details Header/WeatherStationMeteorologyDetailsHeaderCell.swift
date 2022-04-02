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
  
  private lazy var backgroundColorView = Factory.View.make(fromType: .standard(cornerRadiusWeight: .medium))
  
  private lazy var weatherConditionSymbolImageView = Factory.ImageView.make(fromType: .weatherConditionSymbol)
  
  private lazy var weatherConditionTitleLabel = Factory.Label.make(fromType: .headline(textColor: Constants.Theme.Color.ViewElement.WeatherInformation.colorBackgroundPrimaryTitle))
  private lazy var currentTemperatureLabel = Factory.Label.make(fromType: .headline(alignment: .right, textColor: Constants.Theme.Color.ViewElement.WeatherInformation.colorBackgroundPrimaryTitle))
  
  private lazy var temperatureHighLowImageView = Factory.ImageView.make(fromType: .symbol(systemImageName: "thermometer"))
  private lazy var temperatureHighLowLabel = Factory.Label.make(fromType: .subtitle(textColor: Constants.Theme.Color.ViewElement.WeatherInformation.colorBackgroundPrimaryTitle))
  
  private lazy var temperatureFeelsLikeImageView = Factory.ImageView.make(fromType: .symbol(systemImageName: "figure.stand"))
  private lazy var temperatureFeelsLikeLabel = Factory.Label.make(fromType: .subtitle(alignment: .right, textColor: Constants.Theme.Color.ViewElement.WeatherInformation.colorBackgroundPrimaryTitle))
  
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
//    let gradientLayer = Factory.GradientLayer.make(fromType: .weatherCell(
//      frame: backgroundColorView.bounds,
//      cornerRadiusWeight: .medium,
//      baseColor: cellModel.backgroundColor
//    ))
//    backgroundColorView.layer.insertSublayer(gradientLayer, at: 0)
    backgroundColorView.backgroundColor = cellModel.backgroundColor
  
    weatherConditionSymbolImageView.image = cellModel.weatherConditionSymbolImage
    weatherConditionTitleLabel.text = cellModel.weatherConditionTitle
    currentTemperatureLabel.text = cellModel.currentTemperature
    temperatureHighLowLabel.text = cellModel.temperatureHighLow
    temperatureFeelsLikeLabel.text = cellModel.feelsLikeTemperature
  }
  
  func layoutUserInterface() {
    contentView.addSubview(backgroundColorView, constraints: [
      backgroundColorView.topAnchor.constraint(equalTo: contentView.topAnchor),
      backgroundColorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      backgroundColorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      backgroundColorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
    ])
    
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
      weatherConditionTitleLabel.topAnchor.constraint(equalTo: weatherConditionSymbolImageView.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .small)),
      weatherConditionTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CellContentInsets.leading(from: .medium))
    ])
    
    contentView.addSubview(currentTemperatureLabel, constraints: [
      currentTemperatureLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.ContentElement.height),
      currentTemperatureLabel.widthAnchor.constraint(equalTo: weatherConditionTitleLabel.widthAnchor),
      currentTemperatureLabel.topAnchor.constraint(equalTo: weatherConditionSymbolImageView.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .small)),
      currentTemperatureLabel.leadingAnchor.constraint(equalTo: weatherConditionTitleLabel.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .small)),
      currentTemperatureLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CellContentInsets.trailing(from: .medium))
    ])
    
    contentView.addSubview(temperatureHighLowImageView, constraints: [
      temperatureHighLowImageView.heightAnchor.constraint(equalToConstant: Constants.Dimensions.TableCellImage.foregroundHeight),
      temperatureHighLowImageView.widthAnchor.constraint(equalToConstant: Constants.Dimensions.TableCellImage.foregroundHeight),
      temperatureHighLowImageView.topAnchor.constraint(greaterThanOrEqualTo: weatherConditionTitleLabel.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .small)),
      temperatureHighLowImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .large)),
      temperatureHighLowImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CellContentInsets.leading(from: .medium))
    ])
    
    contentView.addSubview(temperatureHighLowLabel, constraints: [
      temperatureHighLowLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.ContentElement.height),
      temperatureHighLowLabel.topAnchor.constraint(equalTo: weatherConditionTitleLabel.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .small)),
      temperatureHighLowLabel.leadingAnchor.constraint(equalTo: temperatureHighLowImageView.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .small)),
      temperatureHighLowLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .large)),
      temperatureHighLowLabel.centerYAnchor.constraint(equalTo: temperatureHighLowImageView.centerYAnchor)
    ])
    
    contentView.addSubview(temperatureFeelsLikeLabel, constraints: [
      temperatureFeelsLikeLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.ContentElement.height),
      temperatureFeelsLikeLabel.widthAnchor.constraint(equalTo: temperatureHighLowLabel.widthAnchor),
      temperatureFeelsLikeLabel.topAnchor.constraint(equalTo: currentTemperatureLabel.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .small)),
      temperatureFeelsLikeLabel.leadingAnchor.constraint(equalTo: temperatureHighLowLabel.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .small)),
      temperatureFeelsLikeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .large)),
      temperatureFeelsLikeLabel.centerYAnchor.constraint(equalTo: temperatureHighLowLabel.centerYAnchor)
    ])
    
    contentView.addSubview(temperatureFeelsLikeImageView, constraints: [
      temperatureFeelsLikeImageView.heightAnchor.constraint(equalToConstant: Constants.Dimensions.TableCellImage.foregroundHeight),
      temperatureFeelsLikeImageView.widthAnchor.constraint(equalToConstant: Constants.Dimensions.TableCellImage.foregroundHeight),
      temperatureFeelsLikeImageView.topAnchor.constraint(greaterThanOrEqualTo: currentTemperatureLabel.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .small)),
      temperatureFeelsLikeImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .large)),
      temperatureFeelsLikeImageView.leadingAnchor.constraint(equalTo: temperatureFeelsLikeLabel.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .small)),
      temperatureFeelsLikeImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CellContentInsets.trailing(from: .medium)),
      temperatureFeelsLikeImageView.centerYAnchor.constraint(equalTo: temperatureFeelsLikeLabel.centerYAnchor)
    ])
  }
  
  func setupAppearance() {
    selectionStyle = .none
    backgroundColor = .clear
    contentView.backgroundColor = .clear
  }
}
