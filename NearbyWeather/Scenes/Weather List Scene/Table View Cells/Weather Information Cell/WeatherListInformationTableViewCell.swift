//
//  WeatherListTableViewCell.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxSwift

// MARK: - Definitions

private extension WeatherListInformationTableViewCell {
  struct Definitions {
    static let backgroundColorViewBorderWidth: CGFloat = 1/UIScreen.main.scale
    static let mainContentStackViewTopBottomInset: CGFloat = 20
    static let mainContentStackViewTrailingInset: CGFloat = 40
    static let weatherConditionSymbolHeight: CGFloat = 60
    static let conditionDetailSymbolHeightWidth: CGFloat = 15
    static let conditionDetailLabelHeight: CGFloat = 24
    static let placeNameLabelHeight: CGFloat = 28
  }
}

// MARK: - Class Definition

final class WeatherListInformationTableViewCell: UITableViewCell, BaseCell {
  
  typealias CellViewModel = WeatherListInformationTableViewCellViewModel
  private typealias CellContentInsets = Constants.Dimensions.Spacing.ContentInsets
  private typealias CellInterelementSpacing = Constants.Dimensions.Spacing.InterElementSpacing
  
  // MARK: - UIComponents
  
  private lazy var backgroundColorView = Factory.View.make(fromType: .standard(cornerRadiusWeight: .medium))
  
  private lazy var weatherConditionSymbolLabel = Factory.Label.make(fromType: .weatherSymbol)
  private lazy var placeNameLabel = Factory.Label.make(fromType: .headline(textColor: Constants.Theme.Color.ViewElement.WeatherInformation.colorBackgroundPrimaryTitle))
  
  private lazy var temperatureSymbolImageView = Factory.ImageView.make(fromType: .symbol(systemImageName: "thermometer"))
  private lazy var temperatureLabel = Factory.Label.make(fromType: .subtitle(numberOfLines: 1, textColor: Constants.Theme.Color.ViewElement.WeatherInformation.colorBackgroundPrimaryTitle))
  
  private lazy var cloudCoverageSymbolImageView = Factory.ImageView.make(fromType: .symbol(systemImageName: "cloud"))
  private lazy var cloudCoverageLabel = Factory.Label.make(fromType: .subtitle(numberOfLines: 1, textColor: Constants.Theme.Color.ViewElement.WeatherInformation.colorBackgroundPrimaryTitle))
  
  private lazy var humiditySymbolImageView = Factory.ImageView.make(fromType: .symbol(systemImageName: "humidity"))
  private lazy var humidityLabel = Factory.Label.make(fromType: .subtitle(numberOfLines: 1, textColor: Constants.Theme.Color.ViewElement.WeatherInformation.colorBackgroundPrimaryTitle))
  
  private lazy var windspeedSymbolImageView = Factory.ImageView.make(fromType: .symbol(systemImageName: "wind"))
  private lazy var windspeedLabel = Factory.Label.make(fromType: .subtitle(numberOfLines: 1, textColor: Constants.Theme.Color.ViewElement.WeatherInformation.colorBackgroundPrimaryTitle))
  
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
    guard let cellViewModel = cellViewModel as? WeatherListInformationTableViewCellViewModel else {
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

extension WeatherListInformationTableViewCell {
  
  func bindContentFromViewModel(_ cellViewModel: CellViewModel) {
    cellViewModel.cellModelDriver
      .drive(onNext: { [setContent] in setContent($0) })
      .disposed(by: disposeBag)
  }
}

// MARK: - Cell Composition

private extension WeatherListInformationTableViewCell {
  
  func setContent(for cellModel: WeatherListInformationTableViewCellModel) {
//    let gradientLayer = Factory.GradientLayer.make(fromType: .weatherCell(
//      frame: backgroundColorView.bounds,
//      cornerRadiusWeight: .medium,
//      baseColor: cellModel.backgroundColor ?? .clear
//    ))
//    backgroundColorView.layer.insertSublayer(gradientLayer, at: 0)
    backgroundColorView.backgroundColor = cellModel.backgroundColor
    
    weatherConditionSymbolLabel.text = cellModel.weatherConditionSymbol
    placeNameLabel.text = cellModel.placeName
    temperatureLabel.text = cellModel.temperature
    cloudCoverageLabel.text = cellModel.cloudCoverage
    humidityLabel.text = cellModel.humidity
    windspeedLabel.text = cellModel.windspeed
  }
  
  func layoutUserInterface() {
    // weather condition
    contentView.addSubview(backgroundColorView, constraints: [
      backgroundColorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CellContentInsets.top(from: .large)),
      backgroundColorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .large)),
      backgroundColorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      backgroundColorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
    ])
    
    contentView.addSubview(weatherConditionSymbolLabel, constraints: [
      weatherConditionSymbolLabel.heightAnchor.constraint(equalToConstant: Definitions.weatherConditionSymbolHeight),
      weatherConditionSymbolLabel.widthAnchor.constraint(equalToConstant: Definitions.weatherConditionSymbolHeight),
      weatherConditionSymbolLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: CellContentInsets.top(from: .large)*2),
      weatherConditionSymbolLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .large)*2),
      weatherConditionSymbolLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CellContentInsets.leading(from: .large)),
      weatherConditionSymbolLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ])
    
    // place name
    contentView.addSubview(placeNameLabel, constraints: [
      placeNameLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Definitions.placeNameLabelHeight),
      placeNameLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: CellContentInsets.top(from: .large)*2),
      placeNameLabel.leadingAnchor.constraint(equalTo: weatherConditionSymbolLabel.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .extraLarge)),
      placeNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CellContentInsets.trailing(from: .large))
    ])
    
    // temperature
    contentView.addSubview(temperatureSymbolImageView, constraints: [
      temperatureSymbolImageView.heightAnchor.constraint(equalToConstant: Definitions.conditionDetailSymbolHeightWidth),
      temperatureSymbolImageView.widthAnchor.constraint(equalToConstant: Definitions.conditionDetailSymbolHeightWidth),
      temperatureSymbolImageView.leadingAnchor.constraint(equalTo: weatherConditionSymbolLabel.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .extraLarge)),
      temperatureSymbolImageView.topAnchor.constraint(greaterThanOrEqualTo: placeNameLabel.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .large))
    ])
    
    contentView.addSubview(temperatureLabel, constraints: [
      temperatureLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Definitions.conditionDetailLabelHeight),
      temperatureLabel.centerYAnchor.constraint(equalTo: temperatureSymbolImageView.centerYAnchor),
      temperatureLabel.leadingAnchor.constraint(equalTo: temperatureSymbolImageView.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .medium)),
      temperatureLabel.topAnchor.constraint(equalTo: placeNameLabel.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .large)),
      temperatureLabel.centerYAnchor.constraint(equalTo: temperatureSymbolImageView.centerYAnchor)
    ])
    
    // cloud coverage
    contentView.addSubview(cloudCoverageSymbolImageView, constraints: [
      cloudCoverageSymbolImageView.heightAnchor.constraint(equalToConstant: Definitions.conditionDetailSymbolHeightWidth),
      cloudCoverageSymbolImageView.widthAnchor.constraint(equalToConstant: Definitions.conditionDetailSymbolHeightWidth),
      cloudCoverageSymbolImageView.leadingAnchor.constraint(equalTo: temperatureLabel.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .large)),
      cloudCoverageSymbolImageView.topAnchor.constraint(greaterThanOrEqualTo: placeNameLabel.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .large)),
      cloudCoverageSymbolImageView.centerYAnchor.constraint(equalTo: temperatureSymbolImageView.centerYAnchor),
      cloudCoverageSymbolImageView.centerYAnchor.constraint(equalTo: temperatureLabel.centerYAnchor)
    ])
    
    contentView.addSubview(cloudCoverageLabel, constraints: [
      cloudCoverageLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Definitions.conditionDetailLabelHeight),
      cloudCoverageLabel.widthAnchor.constraint(equalTo: temperatureLabel.widthAnchor),
      cloudCoverageLabel.leadingAnchor.constraint(equalTo: cloudCoverageSymbolImageView.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .medium)),
      cloudCoverageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CellContentInsets.trailing(from: .large)),
      cloudCoverageLabel.topAnchor.constraint(equalTo: placeNameLabel.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .large)),
      cloudCoverageLabel.centerYAnchor.constraint(equalTo: temperatureSymbolImageView.centerYAnchor),
      cloudCoverageLabel.centerYAnchor.constraint(equalTo: temperatureLabel.centerYAnchor),
      cloudCoverageLabel.centerYAnchor.constraint(equalTo: cloudCoverageSymbolImageView.centerYAnchor)
    ])
    
    // humidity
    contentView.addSubview(humiditySymbolImageView, constraints: [
      humiditySymbolImageView.heightAnchor.constraint(equalToConstant: Definitions.conditionDetailSymbolHeightWidth),
      humiditySymbolImageView.widthAnchor.constraint(equalToConstant: Definitions.conditionDetailSymbolHeightWidth),
      humiditySymbolImageView.leadingAnchor.constraint(equalTo: weatherConditionSymbolLabel.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .extraLarge)),
      humiditySymbolImageView.topAnchor.constraint(greaterThanOrEqualTo: temperatureSymbolImageView.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .large)),
      humiditySymbolImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .extraLarge)*2)
    ])
    
    contentView.addSubview(humidityLabel, constraints: [
      humidityLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Definitions.conditionDetailLabelHeight),
      humidityLabel.widthAnchor.constraint(equalTo: temperatureLabel.widthAnchor),
      humidityLabel.widthAnchor.constraint(equalTo: cloudCoverageLabel.widthAnchor),
      humidityLabel.leadingAnchor.constraint(equalTo: humiditySymbolImageView.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .medium)),
      humidityLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .large)),
      humidityLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .extraLarge)*2),
      humidityLabel.centerYAnchor.constraint(equalTo: humiditySymbolImageView.centerYAnchor)
    ])
    
    // windspeed
    contentView.addSubview(windspeedSymbolImageView, constraints: [
      windspeedSymbolImageView.heightAnchor.constraint(equalToConstant: Definitions.conditionDetailSymbolHeightWidth),
      windspeedSymbolImageView.widthAnchor.constraint(equalToConstant: Definitions.conditionDetailSymbolHeightWidth),
      windspeedSymbolImageView.leadingAnchor.constraint(equalTo: humidityLabel.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .large)),
      windspeedSymbolImageView.topAnchor.constraint(greaterThanOrEqualTo: cloudCoverageSymbolImageView.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .large)),
      windspeedSymbolImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .extraLarge)*2),
      windspeedSymbolImageView.centerYAnchor.constraint(equalTo: humiditySymbolImageView.centerYAnchor),
      windspeedSymbolImageView.centerYAnchor.constraint(equalTo: humidityLabel.centerYAnchor)
    ])
    
    contentView.addSubview(windspeedLabel, constraints: [
      windspeedLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Definitions.conditionDetailLabelHeight),
      windspeedLabel.widthAnchor.constraint(equalTo: temperatureLabel.widthAnchor),
      windspeedLabel.widthAnchor.constraint(equalTo: cloudCoverageLabel.widthAnchor),
      windspeedLabel.widthAnchor.constraint(equalTo: humidityLabel.widthAnchor),
      windspeedLabel.leadingAnchor.constraint(equalTo: windspeedSymbolImageView.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .medium)),
      windspeedLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CellContentInsets.trailing(from: .large)),
      windspeedLabel.topAnchor.constraint(equalTo: cloudCoverageLabel.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .large)),
      windspeedLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .extraLarge)*2),
      windspeedLabel.centerYAnchor.constraint(equalTo: humiditySymbolImageView.centerYAnchor),
      windspeedLabel.centerYAnchor.constraint(equalTo: humidityLabel.centerYAnchor),
      windspeedLabel.centerYAnchor.constraint(equalTo: windspeedSymbolImageView.centerYAnchor)
    ])
  }
  
  func setupAppearance() {
    selectionStyle = .none
    backgroundColor = .clear
    contentView.backgroundColor = .clear
  }
}
