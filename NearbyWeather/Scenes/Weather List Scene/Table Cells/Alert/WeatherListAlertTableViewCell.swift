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
  
  // MARK: - UIComponents
  
  private lazy var backgroundColorView = Factory.View.make(fromType: .standard(cornerRadiusWeight: .medium))
  private lazy var contentStackView = Factory.StackView.make(fromType: .horizontal(spacingWeight: .large))
  private lazy var alertImageView = Factory.ImageView.make(fromType: .symbol(image: R.image.temperature()))
  private lazy var alertInformationLabel = Factory.Label.make(fromType: .title(numberOfLines: 1))
  
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
    backgroundColorView.backgroundColor = cellModel.backgroundColor
    alertImageView.image = cellModel.alertImage
    alertInformationLabel.text = cellModel.alertInformationText
  }
  
  func layoutUserInterface() {
    contentView.addSubview(backgroundColorView, constraints: [
      backgroundColorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CellContentInsets.top(from: .large)),
      backgroundColorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .large)),
      backgroundColorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CellContentInsets.leading(from: .large)),
      backgroundColorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CellContentInsets.trailing(from: .large))
    ])
    
    contentStackView.addArrangedSubview(alertImageView, constraints: [
      alertImageView.heightAnchor.constraint(equalToConstant: Definitions.alertImageViewHeight),
      alertImageView.widthAnchor.constraint(equalToConstant: Definitions.alertImageViewHeight)
    ])
    contentStackView.addArrangedSubview(alertInformationLabel, constraints: [
      alertInformationLabel.heightAnchor.constraint(equalTo: alertImageView.heightAnchor)
    ])
    
    backgroundColorView.addSubview(contentStackView, constraints: [
      contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CellContentInsets.top(from: .large)),
      contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .large)),
      contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CellContentInsets.leading(from: .large)),
      contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CellContentInsets.trailing(from: .large))
    ])
  }
  
  func setupAppearance() {
    selectionStyle = .none
    backgroundColor = .clear
    contentView.backgroundColor = .clear
  }
}
