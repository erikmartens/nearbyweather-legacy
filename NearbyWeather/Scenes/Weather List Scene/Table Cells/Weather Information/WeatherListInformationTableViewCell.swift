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
    static let backgroundColorViewLeadingInset: CGFloat = 48
    static let mainContentStackViewTopBottomInset: CGFloat = 20
    static let mainContentStackViewTrailingInset: CGFloat = 40
    static let weatherConditionSymbolHeight: CGFloat = 80
    static let conditionDetailSymbolHeightWidth: CGFloat = 15
  }
}

// MARK: - Class Definition

final class WeatherListInformationTableViewCell: UITableViewCell, BaseCell {
  
  typealias CellViewModel = WeatherListInformationTableViewCellViewModel
  
  // MARK: - UIComponents
  
  private lazy var backgroundColorView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = Constants.Dimensions.Size.CornerRadiusSize.from(weight: .medium)
    return view
  }()
  
  private lazy var mainContentStackView = Factory.StackView.make(fromType: .vertical(distribution: .fillEqually, spacing: Constants.Dimensions.Spacing.InterElementSpacing.xDistance(from: .medium)))
  private lazy var lineOneStackView = Factory.StackView.make(fromType: .horizontal(distribution: .fillEqually, spacing: Constants.Dimensions.Spacing.InterElementSpacing.xDistance(from: .medium)))
  private lazy var lineTwoStackView = Factory.StackView.make(fromType: .horizontal(distribution: .fillEqually, spacing: Constants.Dimensions.Spacing.InterElementSpacing.xDistance(from: .medium)))
  
  private lazy var temperatureStackView = Factory.StackView.make(fromType: .horizontal(distribution: .fillProportionally, spacing: Constants.Dimensions.Spacing.InterElementSpacing.xDistance(from: .small)))
  private lazy var cloudCoverageStackView = Factory.StackView.make(fromType: .horizontal(distribution: .fillProportionally, spacing: Constants.Dimensions.Spacing.InterElementSpacing.xDistance(from: .small)))
  private lazy var humidityStackView = Factory.StackView.make(fromType: .horizontal(distribution: .fillProportionally, spacing: Constants.Dimensions.Spacing.InterElementSpacing.xDistance(from: .small)))
  private lazy var windspeedStackView = Factory.StackView.make(fromType: .horizontal(distribution: .fillProportionally, spacing: Constants.Dimensions.Spacing.InterElementSpacing.xDistance(from: .small)))
  
  private lazy var weatherConditionSymbolLabel = Factory.Label.make(fromType: .weatherSymbol)
  private lazy var placeNameLabel = Factory.Label.make(fromType: .title(numberOfLines: 1))
  private lazy var temperatureSymbolImageView = Factory.ImageView.make(fromType: .symbol(image: R.image.temperature()))
  private lazy var temperatureLabel = Factory.Label.make(fromType: .body(numberOfLines: 1))
  private lazy var cloudCoverageSymbolImageView = Factory.ImageView.make(fromType: .symbol(image: R.image.cloudCoverFilled()))
  private lazy var cloudCoverageLabel = Factory.Label.make(fromType: .body(alignment: .right, numberOfLines: 1))
  private lazy var humiditySymbolImageView = Factory.ImageView.make(fromType: .symbol(image: R.image.humidity()))
  private lazy var humidityLabel = Factory.Label.make(fromType: .body(numberOfLines: 1))
  private lazy var windspeedSymbolImageView = Factory.ImageView.make(fromType: .symbol(image: R.image.windSpeed()))
  private lazy var windspeedLabel = Factory.Label.make(fromType: .body(alignment: .right, numberOfLines: 1))
  
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
    guard let cellViewModel = cellViewModel as? WeatherListInformationTableViewCellViewModel else {
      return
    }
    self.cellViewModel = cellViewModel
    bindInputFromViewModel(cellViewModel)
    bindOutputToViewModel(cellViewModel)
  }
}

// MARK: - ViewModel Bindings

extension WeatherListInformationTableViewCell {
  
  internal func bindInputFromViewModel(_ cellViewModel: CellViewModel) {
    cellViewModel.cellModelDriver
      .drive(onNext: { [setContent] in setContent($0) })
      .disposed(by: disposeBag)
  }
  
  internal func bindOutputToViewModel(_ cellViewModel: CellViewModel) {} // nothing to do
}

// MARK: - Cell Composition

private extension WeatherListInformationTableViewCell {
  
  func setContent(for cellModel: WeatherListInformationTableViewCellModel) {
    backgroundColorView.backgroundColor = cellModel.backgroundColor
    weatherConditionSymbolLabel.text = cellModel.weatherConditionSymbol
    temperatureLabel.text = cellModel.temperature
    cloudCoverageLabel.text = cellModel.cloudCoverage
    humidityLabel.text = cellModel.humidity
    windspeedLabel.text = cellModel.windspeed
  }
  
  func layoutUserInterface() {
    // compose stackviews
    temperatureStackView.addArrangedSubview(temperatureSymbolImageView, constraints: [
      temperatureSymbolImageView.heightAnchor.constraint(equalToConstant: Definitions.conditionDetailSymbolHeightWidth),
      temperatureSymbolImageView.widthAnchor.constraint(equalToConstant: Definitions.conditionDetailSymbolHeightWidth)
    ])
    temperatureStackView.addArrangedSubview(temperatureLabel)
    
    cloudCoverageStackView.addArrangedSubview(cloudCoverageSymbolImageView, constraints: [
      cloudCoverageSymbolImageView.heightAnchor.constraint(equalToConstant: Definitions.conditionDetailSymbolHeightWidth),
      cloudCoverageSymbolImageView.widthAnchor.constraint(equalToConstant: Definitions.conditionDetailSymbolHeightWidth)
    ])
    cloudCoverageStackView.addArrangedSubview(cloudCoverageLabel)
    
    lineOneStackView.addArrangedSubview(temperatureStackView)
    lineOneStackView.addArrangedSubview(cloudCoverageStackView)
    
    humidityStackView.addArrangedSubview(humiditySymbolImageView, constraints: [
      humiditySymbolImageView.heightAnchor.constraint(equalToConstant: Definitions.conditionDetailSymbolHeightWidth),
      humiditySymbolImageView.widthAnchor.constraint(equalToConstant: Definitions.conditionDetailSymbolHeightWidth)
    ])
    humidityStackView.addArrangedSubview(humidityLabel)
    
    windspeedStackView.addArrangedSubview(windspeedSymbolImageView, constraints: [
      windspeedSymbolImageView.heightAnchor.constraint(equalToConstant: Definitions.conditionDetailSymbolHeightWidth),
      windspeedSymbolImageView.widthAnchor.constraint(equalToConstant: Definitions.conditionDetailSymbolHeightWidth)
    ])
    windspeedStackView.addArrangedSubview(windspeedLabel)
    
    lineTwoStackView.addArrangedSubview(humidityStackView)
    lineTwoStackView.addArrangedSubview(windspeedStackView)
    
    mainContentStackView.addArrangedSubview(placeNameLabel, constraints: [
      placeNameLabel.heightAnchor.constraint(equalToConstant: Definitions.weatherConditionSymbolHeight)
    ])
    mainContentStackView.addArrangedSubview(lineOneStackView)
    mainContentStackView.addArrangedSubview(lineTwoStackView)
    
    // compose final view
    contentView.addSubview(backgroundColorView, constraints: [
      backgroundColorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.Dimensions.Spacing.TableCellContentInsets.top),
      backgroundColorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.Dimensions.Spacing.TableCellContentInsets.bottom),
      backgroundColorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Definitions.backgroundColorViewLeadingInset),
      backgroundColorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Dimensions.Spacing.TableCellContentInsets.trailing)
    ])
    
    contentView.addSubview(weatherConditionSymbolLabel, constraints: [
      weatherConditionSymbolLabel.heightAnchor.constraint(equalToConstant: Definitions.weatherConditionSymbolHeight),
      weatherConditionSymbolLabel.widthAnchor.constraint(equalToConstant: Definitions.weatherConditionSymbolHeight),
      weatherConditionSymbolLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: Constants.Dimensions.Spacing.TableCellContentInsets.top),
      weatherConditionSymbolLabel.bottomAnchor.constraint(greaterThanOrEqualTo: contentView.bottomAnchor, constant: -Constants.Dimensions.Spacing.TableCellContentInsets.bottom),
      weatherConditionSymbolLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Dimensions.Spacing.TableCellContentInsets.leading),
      weatherConditionSymbolLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ])
    
    contentView.addSubview(mainContentStackView, constraints: [
      mainContentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Definitions.mainContentStackViewTopBottomInset),
      mainContentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Definitions.mainContentStackViewTopBottomInset),
      mainContentStackView.leadingAnchor.constraint(equalTo: weatherConditionSymbolLabel.leadingAnchor, constant: Constants.Dimensions.Spacing.InterElementSpacing.xDistance(from: .large)),
      mainContentStackView.trailingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: -Definitions.mainContentStackViewTrailingInset)
    ])
  }
  
  func setupAppearance() {
    selectionStyle = .none
    backgroundColor = .clear
    contentView.backgroundColor = .clear
  }
}
