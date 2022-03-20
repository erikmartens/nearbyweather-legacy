//
//  WeatherStationCurrentInformationMapCell.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 16.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxSwift

// MARK: - Definitions

private extension WeatherStationMeteorologyDetailsMapCell {
  struct Definitions {
    static let mapViewHeight: CGFloat = 200
    static let symbolWidth: CGFloat = 20
  }
}

// MARK: - Class Definition

final class WeatherStationMeteorologyDetailsMapCell: UITableViewCell, BaseCell {
  
  typealias CellViewModel = WeatherStationMeteorologyDetailsMapCellViewModel
  private typealias CellContentInsets = Constants.Dimensions.Spacing.ContentInsets
  private typealias CellInterelementSpacing = Constants.Dimensions.Spacing.InterElementSpacing
  
  // MARK: - UIComponents
  
  private lazy var mapView = Factory.MapView.make(fromType: .standard(
    frame: CGRect(
      origin: .zero,
      size: CGSize(width: contentView.frame.size.width - 2*CellContentInsets.leading(from: .medium), height: Definitions.mapViewHeight)
    ),
    cornerRadiusWeight: .small,
    isUserInteractionEnabled: false
  ))
  
  private lazy var coordinatesSymbolImageView = Factory.ImageView.make(fromType: .symbol(image: R.image.location()))
  private lazy var coordinatesDescriptionLabel = Factory.Label.make(fromType: .body(text: R.string.localizable.coordinates(), textColor: Constants.Theme.Color.ViewElement.Label.titleDark))
  private lazy var coordinatesLabel = Factory.Label.make(fromType: .subtitle(alignment: .right, isCopyable: true))
  
  private lazy var distanceSymbolImageView = Factory.ImageView.make(fromType: .symbol(image: R.image.distance()))
  private lazy var distanceDescriptionLabel = Factory.Label.make(fromType: .body(text: R.string.localizable.distance(), textColor: Constants.Theme.Color.ViewElement.Label.titleDark))
  private lazy var distanceLabel = Factory.Label.make(fromType: .subtitle(alignment: .right))
  
  private lazy var coordinatesLabelTapGestureRecognizer = UITapGestureRecognizer()
  
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
    guard let cellViewModel = cellViewModel as? WeatherStationMeteorologyDetailsMapCellViewModel else {
      return
    }
    self.cellViewModel = cellViewModel
    mapView.delegate = cellViewModel.mapDelegate
    
    cellViewModel.observeEvents()
    bindContentFromViewModel(cellViewModel)
    bindUserInputToViewModel(cellViewModel)
  }
}

// MARK: - ViewModel Bindings

extension WeatherStationMeteorologyDetailsMapCell {
  
  func bindContentFromViewModel(_ cellViewModel: CellViewModel) {
    cellViewModel.cellModelDriver
      .drive(onNext: { [setContent] in setContent($0) })
      .disposed(by: disposeBag)
    
    cellViewModel.mapDelegate?
      .dataSource
      .asDriver(onErrorJustReturn: nil)
      .filterNil()
      .drive(onNext: { [unowned mapView] mapAnnotationData in
        mapView.annotations.forEach { mapView.removeAnnotation($0) }
        mapView.addAnnotations(mapAnnotationData.annotationItems)
        mapView.focus(onCoordinate: mapAnnotationData.annotationItems.first?.coordinate)
      })
      .disposed(by: disposeBag)
  }
  
  func bindUserInputToViewModel(_ cellViewModel: WeatherStationMeteorologyDetailsMapCellViewModel) {
    coordinatesLabelTapGestureRecognizer.rx
      .event
      .map { _ in () }
      .bind(to: cellViewModel.onDidTapCoordinatesLabelSubject)
      .disposed(by: disposeBag)
  }
}

// MARK: - Cell Composition

private extension WeatherStationMeteorologyDetailsMapCell {
  
  func setContent(for cellModel: WeatherStationMeteorologyDetailsMapCellModel) {
    if let preferredMapTypeValue = cellModel.preferredMapTypeOption?.value {
      switch preferredMapTypeValue {
      case .standard:
        mapView.mapType = .standard
      case .satellite:
        mapView.mapType = .satellite
      case .hybrid:
        mapView.mapType = .hybrid
      }
    }
    coordinatesLabel.text = cellModel.coordinatesString
    distanceLabel.text = cellModel.distanceString
  }
  
  func layoutUserInterface() {
    // map view
    contentView.addSubview(mapView, constraints: [
      mapView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CellContentInsets.top(from: .large)),
      mapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CellContentInsets.leading(from: .medium)),
      mapView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CellContentInsets.leading(from: .medium)),
      mapView.heightAnchor.constraint(equalToConstant: Definitions.mapViewHeight)
    ])
    
    // line 1
    contentView.addSubview(coordinatesSymbolImageView, constraints: [
      coordinatesSymbolImageView.topAnchor.constraint(greaterThanOrEqualTo: mapView.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .extraLarge)),
      coordinatesSymbolImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CellContentInsets.leading(from: .medium)),
      coordinatesSymbolImageView.widthAnchor.constraint(equalToConstant: Definitions.symbolWidth),
      coordinatesSymbolImageView.heightAnchor.constraint(equalTo: coordinatesSymbolImageView.widthAnchor)
    ])
    
    contentView.addSubview(coordinatesDescriptionLabel, constraints: [
      coordinatesDescriptionLabel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .extraLarge)),
      coordinatesDescriptionLabel.leadingAnchor.constraint(equalTo: coordinatesSymbolImageView.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .small)),
      coordinatesDescriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.ContentElement.height),
      coordinatesDescriptionLabel.centerYAnchor.constraint(equalTo: coordinatesSymbolImageView.centerYAnchor)
    ])
    
    contentView.addSubview(coordinatesLabel, constraints: [
      coordinatesLabel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .extraLarge)),
      coordinatesLabel.leadingAnchor.constraint(equalTo: coordinatesDescriptionLabel.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .small)),
      coordinatesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CellContentInsets.leading(from: .medium)),
      coordinatesLabel.widthAnchor.constraint(equalTo: coordinatesDescriptionLabel.widthAnchor, multiplier: 4/5),
      coordinatesLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.ContentElement.height),
      coordinatesLabel.centerYAnchor.constraint(equalTo: coordinatesDescriptionLabel.centerYAnchor),
      coordinatesLabel.centerYAnchor.constraint(equalTo: coordinatesSymbolImageView.centerYAnchor)
    ])
    
    // line 2
    contentView.addSubview(distanceSymbolImageView, constraints: [
      distanceSymbolImageView.topAnchor.constraint(greaterThanOrEqualTo: coordinatesSymbolImageView.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .medium)),
      distanceSymbolImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CellContentInsets.leading(from: .medium)),
      distanceSymbolImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .medium)),
      distanceSymbolImageView.widthAnchor.constraint(equalToConstant: Definitions.symbolWidth),
      distanceSymbolImageView.heightAnchor.constraint(equalTo: distanceSymbolImageView.widthAnchor)
    ])
    
    contentView.addSubview(distanceDescriptionLabel, constraints: [
      distanceDescriptionLabel.topAnchor.constraint(equalTo: coordinatesDescriptionLabel.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .medium)),
      distanceDescriptionLabel.leadingAnchor.constraint(equalTo: distanceSymbolImageView.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .small)),
      distanceDescriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .medium)),
      distanceDescriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.ContentElement.height),
      distanceDescriptionLabel.centerYAnchor.constraint(equalTo: distanceSymbolImageView.centerYAnchor)
    ])
    
    contentView.addSubview(distanceLabel, constraints: [
      distanceLabel.topAnchor.constraint(equalTo: coordinatesLabel.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .medium)),
      distanceLabel.leadingAnchor.constraint(equalTo: distanceDescriptionLabel.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .small)),
      distanceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CellContentInsets.leading(from: .medium)),
      distanceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .medium)),
      distanceLabel.widthAnchor.constraint(equalTo: distanceDescriptionLabel.widthAnchor, multiplier: 4/5),
      distanceLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.ContentElement.height),
      distanceLabel.centerYAnchor.constraint(equalTo: distanceDescriptionLabel.centerYAnchor),
      distanceLabel.centerYAnchor.constraint(equalTo: distanceSymbolImageView.centerYAnchor)
    ])
    
    coordinatesLabel.addGestureRecognizer(coordinatesLabelTapGestureRecognizer)
  }
  
  func setupAppearance() {
    selectionStyle = .none
    backgroundColor = .clear
    contentView.backgroundColor = Constants.Theme.Color.ViewElement.primaryBackground
  }
}
