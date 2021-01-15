//
//  ImagedToggleCell.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 13.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit

class ImagedToggleCell: UITableViewCell {
  
  private typealias CellContentInsets = Constants.Dimensions.Spacing.ContentInsets
  private typealias CellInterelementSpacing = Constants.Dimensions.Spacing.InterElementSpacing
  
  private lazy var contentLabel = Factory.Label.make(fromType: .body())
  private lazy var leadingImageView = Factory.ImageView.make(fromType: .cellPrefix)
  private lazy var toggleSwitch = UISwitch()
  
  private var toggleSwitchHandler: ((UISwitch) -> Void)?
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    composeCell()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    toggleSwitchHandler = nil
    toggleSwitch.removeTarget(self, action: #selector(Self.toggleSwitchChanged(_:)), for: .valueChanged)
  }
}

extension ImagedToggleCell {
  
  func configure(
    withTitle title: String,
    image: UIImage?,
    imageBackgroundColor: UIColor,
    toggleIsOnHandler: ((UISwitch) -> Void)?,
    toggleSwitchHandler: ((UISwitch) -> Void)?
  ) {
    contentLabel.text = title
    leadingImageView.image = image
    leadingImageView.backgroundColor = imageBackgroundColor
    
    toggleIsOnHandler?(toggleSwitch)
    
    self.toggleSwitchHandler = toggleSwitchHandler
    toggleSwitch.addTarget(self, action: #selector(Self.toggleSwitchChanged), for: .valueChanged)
  }
}

private extension ImagedToggleCell {
  
  @objc func toggleSwitchChanged(_ sender: UISwitch) {
    toggleSwitchHandler?(sender)
  }
  
  func composeCell() {
    separatorInset = UIEdgeInsets(
      top: 0,
      left: CellContentInsets.leading(from: .large)
        + Constants.Dimensions.Size.TableCellImageSize.width
        + Constants.Dimensions.Spacing.InterElementSpacing.yDistance(from: .small),
      bottom: 0,
      right: 0
    )
    
    contentView.addSubview(leadingImageView, constraints: [
      leadingImageView.heightAnchor.constraint(equalToConstant: Constants.Dimensions.Size.TableCellImageSize.height),
      leadingImageView.widthAnchor.constraint(equalToConstant: Constants.Dimensions.Size.TableCellImageSize.width),
      leadingImageView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: CellContentInsets.top(from: .large)),
      leadingImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .large)),
      leadingImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CellContentInsets.leading(from: .large)),
      leadingImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ])
    
    contentView.addSubview(contentLabel, constraints: [
      contentLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.Size.ContentElementSize.height),
      contentLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CellContentInsets.top(from: .large)),
      contentLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .large)),
      contentLabel.leadingAnchor.constraint(equalTo: leadingImageView.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .small)),
      contentLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ])
    
    contentView.addSubview(toggleSwitch, constraints: [
      toggleSwitch.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CellContentInsets.top(from: .large)),
      toggleSwitch.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .large)),
      toggleSwitch.leadingAnchor.constraint(equalTo: contentLabel.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .small)),
      toggleSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CellContentInsets.trailing(from: .large)),
      toggleSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ])
  }
}
