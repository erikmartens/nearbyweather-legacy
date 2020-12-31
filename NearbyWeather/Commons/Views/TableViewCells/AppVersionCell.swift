//
//  AppVersionCell.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit

class AppVersionCell: UITableViewCell, ReuseIdentifiable {
  
  private lazy var mainImageView = Factory.ImageView.make(fromType: .appIcon)
  private lazy var titleLabel = Factory.Label.make(fromType: .title(alignment: .center, numberOfLines: 0))
  private lazy var subtitleLabel = Factory.Label.make(fromType: .description(alignment: .center, numberOfLines: 0))
  
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
      mainImageView.heightAnchor.constraint(equalToConstant: Constants.Dimensions.AppIconImageSize.height),
      mainImageView.widthAnchor.constraint(equalToConstant: Constants.Dimensions.AppIconImageSize.width),
      mainImageView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: Constants.Dimensions.TableCellContentInsets.top),
      mainImageView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: Constants.Dimensions.TableCellContentInsets.leading),
      mainImageView.trailingAnchor.constraint(greaterThanOrEqualTo: contentView.trailingAnchor, constant: Constants.Dimensions.TableCellContentInsets.trailing),
      mainImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
    ])
    
    contentView.addSubview(titleLabel, constraints: [
      titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.ContentElement.height),
      titleLabel.topAnchor.constraint(equalTo: mainImageView.bottomAnchor, constant: Constants.Dimensions.TableCellContentInsets.interElementYDistance(from: .medium)),
      titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Dimensions.TableCellContentInsets.leading),
      titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Dimensions.TableCellContentInsets.trailing)
    ])
    
    contentView.addSubview(subtitleLabel, constraints: [
      subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.Dimensions.TableCellContentInsets.interElementYDistance(from: .medium)),
      subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.Dimensions.TableCellContentInsets.bottom),
      subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Dimensions.TableCellContentInsets.leading),
      subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Dimensions.TableCellContentInsets.trailing)
    ])
  }
}
