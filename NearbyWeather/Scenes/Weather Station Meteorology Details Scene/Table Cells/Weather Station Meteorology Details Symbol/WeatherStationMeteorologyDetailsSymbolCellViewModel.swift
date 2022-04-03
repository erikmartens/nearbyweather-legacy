//
//  WeatherStationMeteorologyDetailsSymbolCellViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 02.04.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa
import RxFlow

// MARK: - Dependencies

extension WeatherStationMeteorologyDetailsSymbolCellViewModel {
  struct Dependencies {
    let symbolImageName: String?
    let symbolImageRotationAngle: CGFloat?
    let contentLabelText: String
    let descriptionLabelText: String
    let copyText: String?
    let selectable: Bool
    let disclosable: Bool
    let routingIntent: Step?
    
    init(
      symbolImageName: String?,
      symbolImageRotationAngle: CGFloat? = nil,
      contentLabelText: String,
      descriptionLabelText: String,
      copyText: String? = nil,
      selectable: Bool = false,
      disclosable: Bool = false,
      routingIntent: Step? = nil
    ) {
      self.symbolImageName = symbolImageName
      self.symbolImageRotationAngle = symbolImageRotationAngle
      self.contentLabelText = contentLabelText
      self.descriptionLabelText = descriptionLabelText
      self.copyText = copyText
      self.selectable = selectable
      self.disclosable = disclosable
      self.routingIntent = routingIntent
    }
  }
}

// MARK: - Class Definition

final class WeatherStationMeteorologyDetailsSymbolCellViewModel: NSObject, BaseCellViewModel {
  
  let associatedCellReuseIdentifier = WeatherStationMeteorologyDetailsSymbolCell.reuseIdentifier
  lazy var onSelectedRoutingIntent: Step? = {
    dependencies.routingIntent
  }()
  
  lazy var copyText: String?  = dependencies.copyText
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  private let dependencies: Dependencies

  // MARK: - Events
  
  // MARK: - Observables
  
  // MARK: - Drivers
  
  lazy var cellModelDriver: Driver<WeatherStationMeteorologyDetailsSymbolCellModel> = Self.createCellModelDriver(with: dependencies)

  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }
  
  // MARK: - Functions
  
  func observeEvents() {
    observeDataSource()
    observeUserTapEvents()
  }
}

// MARK: - Observation Helpers

private extension WeatherStationMeteorologyDetailsSymbolCellViewModel {
  
  static func createCellModelDriver(with dependencies: Dependencies) -> Driver<WeatherStationMeteorologyDetailsSymbolCellModel> {
    Observable
      .just(
        WeatherStationMeteorologyDetailsSymbolCellModel(
          symbolImageName: dependencies.symbolImageName,
          symbolImageRotationAngle: dependencies.symbolImageRotationAngle,
          contentLabelText: dependencies.contentLabelText,
          descriptionLabelText: dependencies.descriptionLabelText,
          selectable: dependencies.selectable,
          disclosable: dependencies.disclosable
        )
      )
      .asDriver(onErrorJustReturn: WeatherStationMeteorologyDetailsSymbolCellModel())
  }
}
