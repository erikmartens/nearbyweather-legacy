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
    let preferredBookmarkOption: PreferredBookmarkOption?
    let bookmarkedLocations: [WeatherStationDTO]
    weak var selectionDelegate: PreferredBookmarkSelectionAlertDelegate?
  }
}
// MARK: - Class Definition

final class PreferredBookmarkSelectionAlert {
  
  // MARK: - Actions
  
  fileprivate lazy var noneAction = Factory.AlertAction.make(fromType: .standard(title: R.string.localizable.none(), destructive: true, handler: { [dependencies] _ in
    dependencies.selectionDelegate?.didSelectPreferredBookmarkOption(PreferredBookmarkOption(value: .notSet))
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

private extension UIAlertAction {
  
  func setCheckmarkForOption(withAssociatedStation identifier: Int, currentlySelectedStationIdentifier: Int?) {
    guard let currentlySelectedStationIdentifier = currentlySelectedStationIdentifier, identifier == currentlySelectedStationIdentifier else {
      return
    }
    setValue(true, forKey: Constants.Keys.KeyValueBindings.kChecked)
  }
}

private extension Array where Element == WeatherStationDTO {
  
  func mapToAlertAction(dependencies: PreferredBookmarkSelectionAlert.Dependencies) -> [UIAlertAction] {
    compactMap { weatherStationDTO -> UIAlertAction? in
      let action = Factory.AlertAction.make(fromType: .standard(title: weatherStationDTO.name, handler: { [dependencies] _ in
        dependencies.selectionDelegate?.didSelectPreferredBookmarkOption(PreferredBookmarkOption(value: .set(weatherStationDto: weatherStationDTO)))
      }))
      
      action.setCheckmarkForOption(withAssociatedStation: weatherStationDTO.identifier, currentlySelectedStationIdentifier: dependencies.preferredBookmarkOption?.intValue)
      
      return action
    }
  }
}
