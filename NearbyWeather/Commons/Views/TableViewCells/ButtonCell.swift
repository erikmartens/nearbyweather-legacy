//
//  ButtonCell.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 12.02.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import UIKit

class ButtonCell: UITableViewCell {
  
  private typealias CellContentInsets = Constants.Dimensions.Spacing.ContentInsets
  private typealias CellInterelementSpacing = Constants.Dimensions.Spacing.InterElementSpacing
  
  private lazy var contentLabel = Factory.Label.make(fromType: .body())
  private lazy var leftButton = Factory.Button.make(fromType: .standard(height: Constants.Dimensions.InteractableElement.height))
  private lazy var rightButton = Factory.Button.make(fromType: .standard(height: Constants.Dimensions.InteractableElement.height))
  
  private var leftButtonHandler: ((UIButton) -> Void)?
  private var rightButtonHandler: ((UIButton) -> Void)?
  
  @objc private func leftButtonPressed(_ sender: UIButton) {
    leftButtonHandler?(sender)
  }
  
  @objc private func rightButtonPressed(_ sender: UIButton) {
    rightButtonHandler?(sender)
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    composeCell()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    leftButtonHandler = nil
    leftButton.removeTarget(self, action: #selector(Self.leftButtonPressed(_:)), for: .touchUpInside)
    
    rightButtonHandler = nil
    rightButton.removeTarget(self, action: #selector(Self.rightButtonPressed(_:)), for: .touchUpInside)
  }
  
}

extension ButtonCell {
  
  func configure(
    withTitle title: String,
    leftButtonTitle: String,
    rightButtonTitle: String,
    leftButtonHandler: @escaping ((UIButton) -> Void),
    rightButtonHandler: @escaping ((UIButton) -> Void)
  ) {
    contentLabel.text = title
    
    self.rightButtonHandler = rightButtonHandler
    self.leftButtonHandler = leftButtonHandler
    
    leftButton.setTitle(leftButtonTitle, for: UIControl.State())
    leftButton.addTarget(self, action: #selector(ButtonCell.leftButtonPressed(_:)), for: .touchUpInside)
    
    rightButton.setTitle(rightButtonTitle, for: UIControl.State())
    rightButton.addTarget(self, action: #selector(ButtonCell.rightButtonPressed(_:)), for: .touchUpInside)
  }
}

private extension ButtonCell {
  
  func composeCell() {
    contentView.addSubview(contentLabel, constraints: [
      contentLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.ContentElement.height),
      contentLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
      contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CellContentInsets.leading(from: .large)),
      contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CellContentInsets.trailing(from: .large))
    ])
    
    contentView.addSubview(leftButton, constraints: [
      leftButton.heightAnchor.constraint(equalToConstant: Constants.Dimensions.InteractableElement.height),
      leftButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .small)),
      leftButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellInterelementSpacing.xDistance(from: .medium)),
      leftButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CellContentInsets.leading(from: .large))
    ])
    
    contentView.addSubview(rightButton, constraints: [
      rightButton.heightAnchor.constraint(equalToConstant: Constants.Dimensions.InteractableElement.height),
      rightButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .small)),
      rightButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellInterelementSpacing.yDistance(from: .medium)),
      rightButton.leadingAnchor.constraint(equalTo: leftButton.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .large)),
      rightButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CellContentInsets.trailing(from: .large)),
      rightButton.widthAnchor.constraint(equalTo: leftButton.widthAnchor, multiplier: 1)
    ])
  }
}
