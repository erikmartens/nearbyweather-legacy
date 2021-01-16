//
//  WeatherStationCurrentInformationAtmosphericDetailsCell.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 15.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxSwift

// MARK: - Definitions

private extension WeatherStationCurrentInformationAtmosphericDetailsCell {
  struct Definitions {
    static var trailingLeadingContentInsets: CGFloat {
      if #available(iOS 13, *) {
        return CellContentInsets.leading(from: .small)
      }
      return CellContentInsets.leading(from: .medium)
    }
    static let symbolWidth: CGFloat = 20
  }
}

// MARK: - Class Definition

final class WeatherStationCurrentInformationAtmosphericDetailsCell: UITableViewCell, BaseCell { // swiftlint:disable:this type_name
  
  typealias CellViewModel = WeatherStationCurrentInformationAtmosphericDetailsCellViewModel
  private typealias CellContentInsets = Constants.Dimensions.Spacing.ContentInsets
  private typealias CellInterelementSpacing = Constants.Dimensions.Spacing.InterElementSpacing
  
  // MARK: - UIComponents
  
  private lazy var cloudCoverageSymbolImageView = Factory.ImageView.make(fromType: .symbol(image: R.image.cloudCover()))
  private lazy var cloudCoverageDescriptionLabel = Factory.Label.make(fromType: .body(text: R.string.localizable.cloud_coverage(), numberOfLines: 1))
  private lazy var cloudCoverageLabel = Factory.Label.make(fromType: .body(alignment: .right, numberOfLines: 1))
  
  private lazy var humiditySymbolImageView = Factory.ImageView.make(fromType: .symbol(image: R.image.humidity()))
  private lazy var humidityDescriptionLabel = Factory.Label.make(fromType: .body(text: R.string.localizable.humidity(), numberOfLines: 1))
  private lazy var humidityLabel = Factory.Label.make(fromType: .body(alignment: .right, numberOfLines: 1))
  
  private lazy var airPressureSymbolImageView = Factory.ImageView.make(fromType: .symbol(image: R.image.airPressure()))
  private lazy var airPressureDescriptionLabel = Factory.Label.make(fromType: .body(text: R.string.localizable.air_pressure(), numberOfLines: 1))
  private lazy var airPressureLabel = Factory.Label.make(fromType: .body(alignment: .right, numberOfLines: 1))
  
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
    guard let cellViewModel = cellViewModel as? WeatherStationCurrentInformationAtmosphericDetailsCellViewModel else {
      return
    }
    self.cellViewModel = cellViewModel
    cellViewModel.observeEvents()
    bindContentFromViewModel(cellViewModel)
    bindUserInputToViewModel(cellViewModel)
  }
}

// MARK: - ViewModel Bindings

extension WeatherStationCurrentInformationAtmosphericDetailsCell {
  
  func bindContentFromViewModel(_ cellViewModel: CellViewModel) {
    cellViewModel.cellModelDriver
      .drive(onNext: { [setContent] in setContent($0) })
      .disposed(by: disposeBag)
  }
}

// MARK: - Cell Composition

private extension WeatherStationCurrentInformationAtmosphericDetailsCell {
  
  func setContent(for cellModel: WeatherStationCurrentInformationAtmosphericDetailsCellModel) {
    cloudCoverageLabel.text = cellModel.cloudCoverageString
    humidityLabel.text = cellModel.humidityString
    airPressureLabel.text = cellModel.airPressureString
  }
  
  func layoutUserInterface() {
    // line 1
    contentView.addSubview(cloudCoverageSymbolImageView, constraints: [
      cloudCoverageSymbolImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CellContentInsets.top(from: .medium)),
      cloudCoverageSymbolImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Definitions.trailingLeadingContentInsets),
      cloudCoverageSymbolImageView.widthAnchor.constraint(equalToConstant: Definitions.symbolWidth),
      cloudCoverageSymbolImageView.heightAnchor.constraint(equalTo: cloudCoverageSymbolImageView.widthAnchor)
    ])
    
    contentView.addSubview(cloudCoverageDescriptionLabel, constraints: [
      cloudCoverageDescriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CellContentInsets.top(from: .medium)),
      cloudCoverageDescriptionLabel.leadingAnchor.constraint(equalTo: cloudCoverageSymbolImageView.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .small)),
      cloudCoverageDescriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.Size.ContentElementSize.height),
      cloudCoverageDescriptionLabel.centerYAnchor.constraint(equalTo: cloudCoverageSymbolImageView.centerYAnchor)
    ])
    
    contentView.addSubview(cloudCoverageLabel, constraints: [
      cloudCoverageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CellContentInsets.top(from: .medium)),
      cloudCoverageLabel.leadingAnchor.constraint(equalTo: cloudCoverageDescriptionLabel.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .small)),
      cloudCoverageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Definitions.trailingLeadingContentInsets),
      cloudCoverageLabel.widthAnchor.constraint(equalTo: cloudCoverageDescriptionLabel.widthAnchor),
      cloudCoverageLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.Size.ContentElementSize.height),
      cloudCoverageLabel.heightAnchor.constraint(equalTo: cloudCoverageDescriptionLabel.heightAnchor),
      cloudCoverageLabel.centerYAnchor.constraint(equalTo: cloudCoverageDescriptionLabel.centerYAnchor),
      cloudCoverageLabel.centerYAnchor.constraint(equalTo: cloudCoverageSymbolImageView.centerYAnchor)
    ])
    
    // line 2
    contentView.addSubview(humiditySymbolImageView, constraints: [
      humiditySymbolImageView.topAnchor.constraint(equalTo: cloudCoverageSymbolImageView.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .medium)),
      humiditySymbolImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Definitions.trailingLeadingContentInsets),
      humiditySymbolImageView.widthAnchor.constraint(equalToConstant: Definitions.symbolWidth),
      humiditySymbolImageView.heightAnchor.constraint(equalTo: humiditySymbolImageView.widthAnchor)
    ])
    
    contentView.addSubview(humidityDescriptionLabel, constraints: [
      humidityDescriptionLabel.topAnchor.constraint(equalTo: cloudCoverageDescriptionLabel.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .medium)),
      humidityDescriptionLabel.leadingAnchor.constraint(equalTo: humiditySymbolImageView.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .small)),
      humidityDescriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.Size.ContentElementSize.height),
      humidityDescriptionLabel.centerYAnchor.constraint(equalTo: humiditySymbolImageView.centerYAnchor)
    ])
    
    contentView.addSubview(humidityLabel, constraints: [
      humidityLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CellContentInsets.top(from: .medium)),
      humidityLabel.leadingAnchor.constraint(equalTo: humidityDescriptionLabel.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .small)),
      humidityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Definitions.trailingLeadingContentInsets),
      humidityLabel.widthAnchor.constraint(equalTo: humidityDescriptionLabel.widthAnchor),
      humidityLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.Size.ContentElementSize.height),
      humidityLabel.heightAnchor.constraint(equalTo: humidityDescriptionLabel.heightAnchor),
      humidityLabel.centerYAnchor.constraint(equalTo: humidityDescriptionLabel.centerYAnchor),
      humidityLabel.centerYAnchor.constraint(equalTo: humiditySymbolImageView.centerYAnchor)
    ])
    
    // line 3
    contentView.addSubview(airPressureSymbolImageView, constraints: [
      airPressureSymbolImageView.topAnchor.constraint(equalTo: humiditySymbolImageView.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .medium)),
      airPressureSymbolImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Definitions.trailingLeadingContentInsets),
      airPressureSymbolImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .medium)),
      airPressureSymbolImageView.widthAnchor.constraint(equalToConstant: Definitions.symbolWidth),
      airPressureSymbolImageView.centerYAnchor.constraint(equalTo: airPressureSymbolImageView.centerYAnchor)
    ])
    
    contentView.addSubview(airPressureDescriptionLabel, constraints: [
      airPressureDescriptionLabel.topAnchor.constraint(equalTo: humidityDescriptionLabel.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .medium)),
      airPressureDescriptionLabel.leadingAnchor.constraint(equalTo: airPressureSymbolImageView.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .small)),
      airPressureDescriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .medium)),
      airPressureDescriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.Size.ContentElementSize.height),
      airPressureDescriptionLabel.centerYAnchor.constraint(equalTo: airPressureSymbolImageView.centerYAnchor)
    ])
    
    contentView.addSubview(airPressureLabel, constraints: [
      airPressureLabel.topAnchor.constraint(equalTo: humidityDescriptionLabel.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .medium)),
      airPressureLabel.leadingAnchor.constraint(equalTo: airPressureDescriptionLabel.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .small)),
      airPressureLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Definitions.trailingLeadingContentInsets),
      airPressureLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .medium)),
      airPressureLabel.widthAnchor.constraint(equalTo: airPressureDescriptionLabel.widthAnchor),
      airPressureLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.Size.ContentElementSize.height),
      airPressureLabel.heightAnchor.constraint(equalTo: airPressureDescriptionLabel.heightAnchor),
      airPressureLabel.centerYAnchor.constraint(equalTo: airPressureDescriptionLabel.centerYAnchor),
      airPressureLabel.centerYAnchor.constraint(equalTo: airPressureSymbolImageView.centerYAnchor)
    ])
  }
  
  func setupAppearance() {
    selectionStyle = .none
    backgroundColor = .clear
    contentView.backgroundColor = Constants.Theme.Color.ViewElement.secondaryBackground
  }
}
