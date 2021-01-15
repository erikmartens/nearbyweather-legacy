//
//  AppVersionCell.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit

class AppVersionCell: UITableViewCell {
  
  private typealias CellContentInsets = Constants.Dimensions.Spacing.ContentInsets
  private typealias CellInterelementSpacing = Constants.Dimensions.Spacing.InterElementSpacing
  
  private lazy var mainImageView = Factory.ImageView.make(fromType: .appIcon)
  private lazy var titleLabel = Factory.Label.make(fromType: .title(alignment: .center))
  private lazy var subtitleLabel = Factory.Label.make(fromType: .description(alignment: .center))
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    selectionStyle = .none
    backgroundColor = .clear
    contentView.backgroundColor = .clear
    composeCell()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension AppVersionCell {
  
  func configure(
    withImage image: UIImage?,
    title: String,
    subtitle: String
  ) {
    mainImageView.image = image
    titleLabel.text = title
    subtitleLabel.text = subtitle
  }
}

private extension AppVersionCell {
  
  func composeCell() {
    contentView.addSubview(mainImageView, constraints: [
      mainImageView.heightAnchor.constraint(equalToConstant: Constants.Dimensions.Size.AppIconImageSize.height),
      mainImageView.widthAnchor.constraint(equalToConstant: Constants.Dimensions.Size.AppIconImageSize.width),
      mainImageView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: CellContentInsets.top(from: .large)),
      mainImageView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: CellContentInsets.leading(from: .large)),
      mainImageView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -CellContentInsets.trailing(from: .large)),
      mainImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
    ])
    
    contentView.addSubview(titleLabel, constraints: [
      titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.Size.ContentElementSize.height),
      titleLabel.topAnchor.constraint(equalTo: mainImageView.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .medium)),
      titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CellContentInsets.leading(from: .large)),
      titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CellContentInsets.trailing(from: .large))
    ])
    
    contentView.addSubview(subtitleLabel, constraints: [
      subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .medium)),
      subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .large)),
      subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CellContentInsets.leading(from: .large)),
      subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CellContentInsets.trailing(from: .large))
    ])
  }
}
