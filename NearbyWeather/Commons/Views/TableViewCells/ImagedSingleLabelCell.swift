//
//  ImagedSingleLabelCell.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 13.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit

class ImagedSingleLabelCell: UITableViewCell {
  
  static let reuseIdentifier = "ImagedSingleLabelCell"
  
  private lazy var contentLabel: UILabel = {
    let label = UILabel()
    label.font = .preferredFont(forTextStyle: .body)
    return label
  }()
  
  private lazy var leadingImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.tintColor = .white
    imageView.contentMode = .scaleAspectFit
    imageView.layer.cornerRadius = 4
    return imageView
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    composeCell()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension ImagedSingleLabelCell {
  
  func configure(
    withTitle title: String,
    image: UIImage?,
    imageBackgroundColor: UIColor
  ) {
    contentLabel.text = title
    leadingImageView.image = image
    leadingImageView.backgroundColor = imageBackgroundColor
  }
}

private extension ImagedSingleLabelCell {
  
  func composeCell() {
    contentView.addSubview(leadingImageView, constraints: [
      leadingImageView.heightAnchor.constraint(equalToConstant: 28),
      leadingImageView.widthAnchor.constraint(equalToConstant: 28),
      leadingImageView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 4),
      leadingImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -4),
      leadingImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      leadingImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ])
    
    contentView.addSubview(contentLabel, constraints: [
      contentLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 34),
      contentLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
      contentLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
      contentLabel.leadingAnchor.constraint(equalTo: leadingImageView.trailingAnchor, constant: 12),
      contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
      contentLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ])
  }
}
