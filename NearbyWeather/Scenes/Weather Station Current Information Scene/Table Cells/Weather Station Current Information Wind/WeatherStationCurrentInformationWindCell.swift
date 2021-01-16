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

private extension WeatherStationCurrentInformationWindCell {
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

final class WeatherStationCurrentInformationWindCell: UITableViewCell, BaseCell {
  
  typealias CellViewModel = WeatherStationCurrentInformationWindCellViewModel
  private typealias CellContentInsets = Constants.Dimensions.Spacing.ContentInsets
  private typealias CellInterelementSpacing = Constants.Dimensions.Spacing.InterElementSpacing
  
  // MARK: - UIComponents
  
  private lazy var windSpeedSymbolImageView = Factory.ImageView.make(fromType: .symbol(image: R.image.windSpeed()))
  private lazy var windSpeedDescriptionLabel = Factory.Label.make(fromType: .body(text: R.string.localizable.windspeed(), numberOfLines: 1))
  private lazy var windSpeedLabel = Factory.Label.make(fromType: .body(alignment: .right, numberOfLines: 1))
  
  private lazy var windDirectionSymbolImageView = Factory.ImageView.make(fromType: .symbol(image: R.image.windDirection()))
  private lazy var windDirectionDescriptionLabel = Factory.Label.make(fromType: .body(text: R.string.localizable.wind_direction(), numberOfLines: 1))
  private lazy var windDirectionLabel = Factory.Label.make(fromType: .body(alignment: .right, numberOfLines: 1))
  
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
    guard let cellViewModel = cellViewModel as? WeatherStationCurrentInformationWindCellViewModel else {
      return
    }
    self.cellViewModel = cellViewModel
    cellViewModel.observeEvents()
    bindContentFromViewModel(cellViewModel)
    bindUserInputToViewModel(cellViewModel)
  }
}

// MARK: - ViewModel Bindings

extension WeatherStationCurrentInformationWindCell {
  
  func bindContentFromViewModel(_ cellViewModel: CellViewModel) {
    cellViewModel.cellModelDriver
      .drive(onNext: { [setContent] in setContent($0) })
      .disposed(by: disposeBag)
  }
}

// MARK: - Cell Composition

private extension WeatherStationCurrentInformationWindCell {
  
  func setContent(for cellModel: WeatherStationCurrentInformationWindCellModel) {
    windSpeedLabel.text = cellModel.windSpeedString
    if let windDirectionRotationAngle = cellModel.windDirectionRotationAngle {
      windDirectionSymbolImageView.transform = CGAffineTransform(rotationAngle: windDirectionRotationAngle)
    }
    windDirectionLabel.text = cellModel.windDirectionString
  }
  
  func layoutUserInterface() {
    // line 1
    contentView.addSubview(windSpeedSymbolImageView, constraints: [
      windSpeedSymbolImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CellContentInsets.top(from: .medium)),
      windSpeedSymbolImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Definitions.trailingLeadingContentInsets),
      windSpeedSymbolImageView.widthAnchor.constraint(equalToConstant: Definitions.symbolWidth),
      windSpeedSymbolImageView.heightAnchor.constraint(equalTo: windSpeedSymbolImageView.widthAnchor)
    ])
    
    contentView.addSubview(windSpeedDescriptionLabel, constraints: [
      windSpeedDescriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CellContentInsets.top(from: .medium)),
      windSpeedDescriptionLabel.leadingAnchor.constraint(equalTo: windSpeedSymbolImageView.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .small)),
      windSpeedDescriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.Size.ContentElementSize.height),
      windSpeedDescriptionLabel.centerYAnchor.constraint(equalTo: windSpeedSymbolImageView.centerYAnchor)
    ])
    
    contentView.addSubview(windSpeedLabel, constraints: [
      windSpeedLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CellContentInsets.top(from: .medium)),
      windSpeedLabel.leadingAnchor.constraint(equalTo: windSpeedDescriptionLabel.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .small)),
      windSpeedLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Definitions.trailingLeadingContentInsets),
      windSpeedLabel.widthAnchor.constraint(equalTo: windSpeedDescriptionLabel.widthAnchor),
      windSpeedLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.Size.ContentElementSize.height),
      windSpeedLabel.heightAnchor.constraint(equalTo: windSpeedDescriptionLabel.heightAnchor),
      windSpeedLabel.centerYAnchor.constraint(equalTo: windSpeedDescriptionLabel.centerYAnchor),
      windSpeedLabel.centerYAnchor.constraint(equalTo: windSpeedSymbolImageView.centerYAnchor)
    ])
    
    // line 2
    contentView.addSubview(windDirectionSymbolImageView, constraints: [
      windDirectionSymbolImageView.topAnchor.constraint(equalTo: windSpeedSymbolImageView.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .medium)),
      windDirectionSymbolImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Definitions.trailingLeadingContentInsets),
      windDirectionSymbolImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .medium)),
      windDirectionSymbolImageView.widthAnchor.constraint(equalToConstant: Definitions.symbolWidth),
      windDirectionSymbolImageView.heightAnchor.constraint(equalTo: windDirectionSymbolImageView.widthAnchor)
    ])
    
    contentView.addSubview(windDirectionDescriptionLabel, constraints: [
      windDirectionDescriptionLabel.topAnchor.constraint(equalTo: windSpeedDescriptionLabel.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .medium)),
      windDirectionDescriptionLabel.leadingAnchor.constraint(equalTo: windDirectionSymbolImageView.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .small)),
      windDirectionDescriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .medium)),
      windDirectionDescriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.Size.ContentElementSize.height),
      windDirectionDescriptionLabel.centerYAnchor.constraint(equalTo: windDirectionSymbolImageView.centerYAnchor)
    ])
    
    contentView.addSubview(windDirectionLabel, constraints: [
      windDirectionLabel.topAnchor.constraint(equalTo: windSpeedLabel.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .medium)),
      windDirectionLabel.leadingAnchor.constraint(equalTo: windDirectionDescriptionLabel.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .small)),
      windDirectionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Definitions.trailingLeadingContentInsets),
      windDirectionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .medium)),
      windDirectionLabel.widthAnchor.constraint(equalTo: windDirectionDescriptionLabel.widthAnchor),
      windDirectionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.Size.ContentElementSize.height),
      windDirectionLabel.heightAnchor.constraint(equalTo: windDirectionDescriptionLabel.heightAnchor),
      windDirectionLabel.centerYAnchor.constraint(equalTo: windDirectionDescriptionLabel.centerYAnchor),
      windDirectionLabel.centerYAnchor.constraint(equalTo: windDirectionSymbolImageView.centerYAnchor)
    ])
  }
  
  func setupAppearance() {
    selectionStyle = .none
    backgroundColor = .clear
    contentView.backgroundColor = Constants.Theme.Color.ViewElement.secondaryBackground
  }
}
