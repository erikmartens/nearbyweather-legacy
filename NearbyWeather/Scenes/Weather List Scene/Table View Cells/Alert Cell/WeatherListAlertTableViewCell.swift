//
//  WeatherInformationAlertTableViewCell.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 05.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxSwift

private extension WeatherListAlertTableViewCell {
  
  struct Definitions {
    static let alertImageViewHeight: CGFloat = 25
  }
}

final class WeatherListAlertTableViewCell: UITableViewCell, BaseCell {
  
  typealias CellViewModel = WeatherListAlertTableViewCellViewModel
  private typealias CellContentInsets = Constants.Dimensions.Spacing.ContentInsets
  private typealias CellInterelementSpacing = Constants.Dimensions.Spacing.InterElementSpacing
  
  // MARK: - UIComponents
  
  private lazy var contentStackView = Factory.StackView.make(fromType: .horizontal(spacingWeight: .large))
  private lazy var alertImageView = Factory.ImageView.make(fromType: .symbol(image: Factory.Image.make(fromType: .symbol(
    systemImageName: "exclamationmark.bubble.fill",
    tintColor: Constants.Theme.Color.ViewElement.alert.darken(by: 0.25)
  ))))
  private lazy var alertTitleLabel = Factory.Label.make(fromType: .headline(textColor: Constants.Theme.Color.ViewElement.WeatherInformation.colorBackgroundPrimaryTitle))
  private lazy var alertDescriptionLabel = Factory.Label.make(fromType: .subtitle(textColor: Constants.Theme.Color.ViewElement.WeatherInformation.colorBackgroundPrimaryTitle))
  
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
    guard let cellViewModel = cellViewModel as? WeatherListAlertTableViewCellViewModel else {
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

extension WeatherListAlertTableViewCell {
  
  func bindContentFromViewModel(_ cellViewModel: CellViewModel) {
    cellViewModel.cellModelDriver
      .drive(onNext: { [setContent] in setContent($0) })
      .disposed(by: disposeBag)
  }
}

// MARK: - Cell Composition

private extension WeatherListAlertTableViewCell {
  
  func setContent(for cellModel: WeatherListAlertTableViewCellModel) {
    alertTitleLabel.text = cellModel.alertTitle
    alertDescriptionLabel.text = cellModel.alertDescription
  }
  
  func layoutUserInterface() {
    contentView.addSubview(alertImageView, constraints: [
      alertImageView.heightAnchor.constraint(equalToConstant: Definitions.alertImageViewHeight),
      alertImageView.widthAnchor.constraint(equalToConstant: Definitions.alertImageViewHeight),
      alertImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CellContentInsets.top(from: .large)),
      alertImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.topAnchor, constant: -CellContentInsets.bottom(from: .large)),
      alertImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CellContentInsets.leading(from: .large))
    ])
    
    contentView.addSubview(alertTitleLabel, constraints: [
      alertTitleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.ContentElement.height),
      alertTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CellContentInsets.top(from: .large)),
      alertTitleLabel.leadingAnchor.constraint(equalTo: alertImageView.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .medium)),
      alertTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CellContentInsets.trailing(from: .large)),
      alertTitleLabel.firstBaselineAnchor.constraint(equalTo: alertImageView.firstBaselineAnchor)
    ])
    
    contentView.addSubview(alertDescriptionLabel, constraints: [
      alertDescriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.ContentElement.height),
      alertDescriptionLabel.topAnchor.constraint(equalTo: alertTitleLabel.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .medium)),
      alertDescriptionLabel.leadingAnchor.constraint(equalTo: alertImageView.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .medium)),
      alertDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CellContentInsets.trailing(from: .large)),
      alertDescriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .large))
    ])
  }
  
  func setupAppearance() {
    selectionStyle = .none
    backgroundColor = .clear
    contentView.backgroundColor = Constants.Theme.Color.ViewElement.alert
  }
}
