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
  
  typealias BaseCellViewModel = WeatherListAlertTableViewCellViewModel
  
  // MARK: - UIComponents
  
  private lazy var backgroundColorView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = Constants.Dimensions.Size.CornerRadiusSize.from(weight: .medium)
    return view
  }()
  
  private lazy var contentStackView = Factory.StackView.make(fromType: .horizontal(spacing: Constants.Dimensions.Spacing.InterElementSpacing.xDistance(from: .large)))
  private lazy var alertImageView = Factory.ImageView.make(fromType: .symbol(image: R.image.temperature()))
  private lazy var alertInformationLabel = Factory.Label.make(fromType: .title(numberOfLines: 1))
  
  // MARK: - Assets
  
  private var disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  internal var cellViewModel: BaseCellViewModel?
  
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
    bindInputFromViewModel(cellViewModel)
    bindOutputToViewModel(cellViewModel)
  }
}

// MARK: - ViewModel Bindings

extension WeatherListAlertTableViewCell {
  
  internal func bindInputFromViewModel(_ cellViewModel: BaseCellViewModel) {
    cellViewModel.cellModelDriver
      .drive(onNext: { [setContent] in setContent($0) })
      .disposed(by: disposeBag)
  }
  
  internal func bindOutputToViewModel(_ cellViewModel: BaseCellViewModel) {} // nothing to do
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
      backgroundColorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.Dimensions.Spacing.TableCellContentInsets.top),
      backgroundColorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.Dimensions.Spacing.TableCellContentInsets.bottom),
      backgroundColorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Dimensions.Spacing.TableCellContentInsets.leading),
      backgroundColorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Dimensions.Spacing.TableCellContentInsets.trailing)
    ])
    
    contentStackView.addArrangedSubview(alertImageView, constraints: [
      alertImageView.heightAnchor.constraint(equalToConstant: Definitions.alertImageViewHeight),
      alertImageView.widthAnchor.constraint(equalToConstant: Definitions.alertImageViewHeight)
    ])
    contentStackView.addArrangedSubview(alertInformationLabel, constraints: [
      alertInformationLabel.heightAnchor.constraint(equalTo: alertImageView.heightAnchor)
    ])
    
    backgroundColorView.addSubview(contentStackView, constraints: [
      contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.Dimensions.Spacing.ContentInsets.top),
      contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.Dimensions.Spacing.ContentInsets.bottom),
      contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Dimensions.Spacing.ContentInsets.leading),
      contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Dimensions.Spacing.ContentInsets.trailing)
    ])
  }
  
  func setupAppearance() {
    selectionStyle = .none
    backgroundColor = .clear
    contentView.backgroundColor = .clear
  }
}
