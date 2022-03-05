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
    static var trailingLeadingContentInsets: CGFloat {
      if #available(iOS 13, *) {
        return CellContentInsets.leading(from: .small)
      }
      return CellContentInsets.leading(from: .medium)
    }
  }
}

// MARK: - Class Definition

final class WeatherStationMeteorologyDetailsHeaderCell: UITableViewCell, BaseCell {
  
  typealias CellViewModel = WeatherStationMeteorologyDetailsHeaderCellViewModel
  private typealias CellContentInsets = Constants.Dimensions.Spacing.ContentInsets
  private typealias CellInterelementSpacing = Constants.Dimensions.Spacing.InterElementSpacing
  
  // MARK: - UIComponents
  
  private lazy var weatherConditionSymbolLabel = Factory.Label.make(fromType: .weatherSymbol)
  
  private lazy var weatherConditionTitleLabel = Factory.Label.make(fromType: .title(numberOfLines: 1))
  private lazy var temperatureLabelLabel = Factory.Label.make(fromType: .title(alignment: .right, numberOfLines: 1))
  
  private lazy var weatherConditionSubtitleLabel = Factory.Label.make(fromType: .body(numberOfLines: 1))
  private lazy var dayTimeStatusLabel = Factory.Label.make(fromType: .body(alignment: .right, numberOfLines: 1))
  
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
    weatherConditionSymbolLabel.text = cellModel.weatherConditionSymbol
    weatherConditionTitleLabel.text = cellModel.weatherConditionTitle
    temperatureLabelLabel.text = cellModel.temperature
    weatherConditionSubtitleLabel.text = cellModel.weatherConditionSubtitle
    dayTimeStatusLabel.text = cellModel.daytimeStatus
  }
  
  func layoutUserInterface() {
    contentView.addSubview(weatherConditionSymbolLabel, constraints: [
      weatherConditionSymbolLabel.heightAnchor.constraint(equalToConstant: Definitions.weatherConditionSymbolWidthHeight),
      weatherConditionSymbolLabel.widthAnchor.constraint(equalToConstant: Definitions.weatherConditionSymbolWidthHeight),
      weatherConditionSymbolLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      weatherConditionSymbolLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
      weatherConditionSymbolLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: Definitions.trailingLeadingContentInsets),
      weatherConditionSymbolLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: Definitions.trailingLeadingContentInsets)
    ])
    
    contentView.addSubview(weatherConditionTitleLabel, constraints: [
      weatherConditionTitleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.ContentElement.height),
      weatherConditionTitleLabel.topAnchor.constraint(equalTo: weatherConditionSymbolLabel.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .small)),
      weatherConditionTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Definitions.trailingLeadingContentInsets)
    ])
    
    contentView.addSubview(temperatureLabelLabel, constraints: [
      temperatureLabelLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.ContentElement.height),
      temperatureLabelLabel.widthAnchor.constraint(equalTo: weatherConditionTitleLabel.widthAnchor),
      temperatureLabelLabel.topAnchor.constraint(equalTo: weatherConditionSymbolLabel.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .small)),
      temperatureLabelLabel.leadingAnchor.constraint(equalTo: weatherConditionTitleLabel.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .small)),
      temperatureLabelLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Definitions.trailingLeadingContentInsets)
    ])
    
    contentView.addSubview(weatherConditionSubtitleLabel, constraints: [
      weatherConditionSubtitleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.ContentElement.height),
      weatherConditionSubtitleLabel.topAnchor.constraint(equalTo: weatherConditionTitleLabel.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .small)),
      weatherConditionSubtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Definitions.trailingLeadingContentInsets),
      weatherConditionSubtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
    ])
    
    contentView.addSubview(dayTimeStatusLabel, constraints: [
      dayTimeStatusLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.ContentElement.height),
      dayTimeStatusLabel.topAnchor.constraint(equalTo: temperatureLabelLabel.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .small)),
      dayTimeStatusLabel.leadingAnchor.constraint(equalTo: weatherConditionSubtitleLabel.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .small)),
      dayTimeStatusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Definitions.trailingLeadingContentInsets),
      dayTimeStatusLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
    ])
  }
  
  func setupAppearance() {
    selectionStyle = .none
    backgroundColor = .clear
    contentView.backgroundColor = .clear
  }
}
