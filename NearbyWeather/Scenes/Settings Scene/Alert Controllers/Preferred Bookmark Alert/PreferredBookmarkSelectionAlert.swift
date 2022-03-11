//
//  PreferredBookmarkSelectionAlert.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 09.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import UIKit.UIAlertController
import CoreLocation.CLLocation
import RxSwift
import RxFlow

// MARK: - Delegate

protocol PreferredBookmarkSelectionAlertDelegate: AnyObject {
  func didSelectPreferredBookmarkOption(_ option: PreferredBookmarkOption)
}

// MARK: - Dependencies

extension PreferredBookmarkSelectionAlert {
  struct Dependencies {
    let preferredBookmarkOption: PreferredBookmarkOption
    let bookmarkedLocations: [WeatherInformationDTO]
    weak var selectionDelegate: PreferredBookmarkSelectionAlertDelegate?
  }
}
// MARK: - Class Definition

final class PreferredBookmarkSelectionAlert {
  
  // MARK: - Actions
  
  fileprivate lazy var noneAction = Factory.AlertAction.make(fromType: .standard(title: R.string.localizable.none(), destructive: true, handler: { [dependencies] _ in
    dependencies.selectionDelegate?.didSelectPreferredBookmarkOption(PreferredBookmarkOption(value: nil))
  }))
  fileprivate lazy var cancelAction = Factory.AlertAction.make(fromType: .cancel)
  
  // MARK: - Properties
  
  let dependencies: Dependencies
  let alertController: UIAlertController
  
  // MARK: - Initialization
  
  required init(dependencies: Dependencies) {
    self.dependencies = dependencies
    
    alertController = UIAlertController(
      title: R.string.localizable.preferred_bookmark().capitalized,
      message: nil,
      preferredStyle: .alert
    )
    
    let actions = dependencies.bookmarkedLocations.mapToAlertAction(dependencies: dependencies) + [noneAction, cancelAction]
    actions.forEach { alertController.addAction($0) }
  }
  
  deinit {
    printDebugMessage(
      domain: String(describing: self),
      message: "was deinitialized",
      type: .info
    )
  }
}

// MARK: - Helper Extensions

private extension Array where Element == WeatherInformationDTO {
  
  func mapToAlertAction(dependencies: PreferredBookmarkSelectionAlert.Dependencies) -> [UIAlertAction] {
    compactMap { weatherInformationDTO -> UIAlertAction? in
      Factory.AlertAction.make(fromType: .standard(title: weatherInformationDTO.stationName, handler: { [dependencies] _ in
          dependencies.selectionDelegate?.didSelectPreferredBookmarkOption(PreferredBookmarkOption(value: weatherInformationDTO.stationIdentifier))
      }))
    }
  }
}
