//
//  WeatherListTableViewCell.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxSwift

final class ListWeatherInformationTableCell: UITableViewCell, BaseCell, ReuseIdentifiable {
  
  typealias CellViewModel = ListWeatherInformationTableCellViewModel
  
  // MARK: - UIComponents
  
//  private lazy var backgroundColorView: UIView = {
//    let view = UIView()
//    view.layer.cornerRadius = Constants.
//  }()
  
  private lazy var weatherConditionSymbolLabel = Factory.Label.make(fromType: .weatherSymbol)
  private lazy var placeNameLabel = Factory.Label.make(fromType: .title(numberOfLines: 1))
  private lazy var temperatureSymbolImageView = Factory.ImageView.make(fromType: .symbol(image: R.image.temperature()))
  private lazy var temperatureLabel = Factory.Label.make(fromType: .body(numberOfLines: 1))
  private lazy var cloudCoverageSymbolImageView = Factory.ImageView.make(fromType: .symbol(image: R.image.cloudCoverFilled()))
  private lazy var cloudCoverageLabel = Factory.Label.make(fromType: .body(alignment: .right, numberOfLines: 1))
  private lazy var humiditySymbolImageView = Factory.ImageView.make(fromType: .symbol(image: R.image.humidity()))
  private lazy var humidityLabel = Factory.Label.make(fromType: .body(numberOfLines: 1))
  private lazy var windspeedSymbolImageView = Factory.ImageView.make(fromType: .symbol(image: R.image.windSpeed()))
  private lazy var windspeedLabel = Factory.Label.make(fromType: .body(alignment: .right, numberOfLines: 1))
  
  // MARK: - Assets
  
  private var disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  private var cellViewModel: CellViewModel?
  
  // MARK: - Initialization
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    selectionStyle = .none
    backgroundColor = .clear
    contentView.backgroundColor = .clear
    
    layoutUserInterface()
    setupAppearance()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Cell Life Cycle
  
  func configure(with cellViewModel: CellViewModel) {
    self.cellViewModel = cellViewModel
    bindInputFromViewModel(cellViewModel)
    bindOutputToViewModel(cellViewModel)
    cellViewModel.observeEvents()
  }
}

// MARK: - ViewModel Bindings

extension ListWeatherInformationTableCell {
  
  private func bindInputFromViewModel(_ viewModel: CellViewModel) {
    viewModel.cellModelSubject
      .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
      .asDriver(onErrorJustReturn: ListWeatherInformationTableCellModel())
      .drive(onNext: { [setContent] in setContent($0) })
      .disposed(by: disposeBag)
  }
  
  private func bindOutputToViewModel(_ viewModel: CellViewModel) {
    // nothing to do
  }
}

// MARK: - Cell Composition

private extension ListWeatherInformationTableCell {
  
  func setContent(for cellModel: ListWeatherInformationTableCellModel) {
//    contentView.addSubview(<#T##subview: S##S#>, constraints: <#T##[NSLayoutConstraint]#>)
  }
  
  func layoutUserInterface() {
    
  }
  
  func setupAppearance() {
    
  }
}
