//
//  ButtonCell.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 12.02.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import UIKit

class ButtonCell: UITableViewCell {
  
  static let reuseIdentifier = "ButtonCell"
  
  private lazy var contentLabel = UILabel()
  private lazy var leftButton = Factory.Button.make(fromType: .standard(height: 34))
  private lazy var rightButton = Factory.Button.make(fromType: .standard(height: 34))
  
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
    leftButton.removeTarget(self, action: #selector(ButtonCell.leftButtonPressed(_:)), for: .touchUpInside)
    
    rightButtonHandler = nil
    rightButton.removeTarget(self, action: #selector(ButtonCell.rightButtonPressed(_:)), for: .touchUpInside)
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
      contentLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 34),
      contentLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
      contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
    ])
    
    contentView.addSubview(leftButton, constraints: [
      leftButton.heightAnchor.constraint(equalToConstant: 34),
      leftButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 4),
      leftButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
      leftButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
    ])
    
    contentView.addSubview(rightButton, constraints: [
      rightButton.heightAnchor.constraint(equalToConstant: 34),
      rightButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 4),
      rightButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
      rightButton.leadingAnchor.constraint(equalTo: leftButton.trailingAnchor, constant: 16),
      rightButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
      rightButton.widthAnchor.constraint(equalTo: leftButton.widthAnchor, multiplier: 1)
    ])
  }
}
