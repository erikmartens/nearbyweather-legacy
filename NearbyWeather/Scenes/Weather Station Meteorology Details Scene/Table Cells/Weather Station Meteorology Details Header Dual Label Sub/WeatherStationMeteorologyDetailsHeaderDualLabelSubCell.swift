//
//  WeatherStationMeteorologyDetailsHeaderDualLabelSubCell.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 02.04.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxSwift

// MARK: - Definitions

private extension WeatherStationMeteorologyDetailsHeaderDualLabelSubCell {
  struct Definitions {
    static let weatherConditionSymbolWidthHeight: CGFloat = 80
  }
}

// MARK: - Class Definition

final class WeatherStationMeteorologyDetailsHeaderDualLabelSubCell: UITableViewCell, BaseCell {
  
  typealias CellViewModel = WeatherStationMeteorologyDetailsHeaderDualLabelSubCellViewModel
  private typealias CellContentInsets = Constants.Dimensions.Spacing.ContentInsets
  private typealias CellInterelementSpacing = Constants.Dimensions.Spacing.InterElementSpacing
  
  // MARK: - UIComponents
  
  private lazy var lhsLabel = Factory.Label.make(fromType: .subtitle(textColor: Constants.Theme.Color.ViewElement.WeatherInformation.colorBackgroundPrimaryTitle))
  private lazy var rhsLabel = Factory.Label.make(fromType: .subtitle(alignment: .right, textColor: Constants.Theme.Color.ViewElement.WeatherInformation.colorBackgroundPrimaryTitle))
  
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
    guard let cellViewModel = cellViewModel as? WeatherStationMeteorologyDetailsHeaderDualLabelSubCellViewModel else {
      return
    }
    self.cellViewModel = cellViewModel
    cellViewModel.observeEvents()
    bindContentFromViewModel(cellViewModel)
    bindUserInputToViewModel(cellViewModel)
  }
}

// MARK: - ViewModel Bindings

extension WeatherStationMeteorologyDetailsHeaderDualLabelSubCell {
  
  func bindContentFromViewModel(_ cellViewModel: CellViewModel) {
    cellViewModel.cellModelDriver
      .drive(onNext: { [setContent] in setContent($0) })
      .disposed(by: disposeBag)
  }
}

// MARK: - Cell Composition

private extension WeatherStationMeteorologyDetailsHeaderDualLabelSubCell {
  
  func setContent(for cellModel: WeatherStationMeteorologyDetailsHeaderDualLabelSubCellModel) {
    contentView.backgroundColor = cellModel.backgroundColor
    lhsLabel.text = cellModel.lhsText
    rhsLabel.text = cellModel.rhsText
  }
  
  func layoutUserInterface() {
    separatorInset = UIEdgeInsets(
      top: 0,
      left: contentView.frame.size.width,
      bottom: 0,
      right: contentView.frame.size.width
    )
    
    contentView.addSubview(lhsLabel, constraints: [
      lhsLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.ContentElement.height),
      lhsLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CellContentInsets.top(from: .large)),
      lhsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CellContentInsets.leading(from: .medium)),
      lhsLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .large))
    ])
    
    contentView.addSubview(rhsLabel, constraints: [
      rhsLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.ContentElement.height),
      rhsLabel.widthAnchor.constraint(equalTo: lhsLabel.widthAnchor),
      rhsLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CellContentInsets.top(from: .large)),
      rhsLabel.leadingAnchor.constraint(equalTo: lhsLabel.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .small)),
      rhsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CellContentInsets.trailing(from: .medium)),
      rhsLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .large)),
      rhsLabel.firstBaselineAnchor.constraint(equalTo: lhsLabel.firstBaselineAnchor)
    ])
  }
  
  func setupAppearance() {
    selectionStyle = .none
    backgroundColor = .clear
  }
}
