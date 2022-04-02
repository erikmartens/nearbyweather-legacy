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
    isUserInteractionEnabled: true
  ))
  
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
    // nothing to do
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
  }
  
  func layoutUserInterface() {
    // map view
    contentView.addSubview(mapView, constraints: [
      mapView.heightAnchor.constraint(equalToConstant: Definitions.mapViewHeight),
      mapView.topAnchor.constraint(equalTo: contentView.topAnchor),
      mapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      mapView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      mapView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
    ])
  }
  
  func setupAppearance() {
    selectionStyle = .none
    backgroundColor = .clear
    contentView.backgroundColor = Constants.Theme.Color.ViewElement.primaryBackground
  }
}
