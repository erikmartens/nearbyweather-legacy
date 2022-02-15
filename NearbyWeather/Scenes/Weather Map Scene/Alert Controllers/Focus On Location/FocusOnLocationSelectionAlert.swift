//
//  FocusOnLocationSelectionAlertController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import UIKit.UIAlertController
import CoreLocation.CLLocation
import RxSwift
import RxFlow

enum FocusOnLocationOption {
  case userLocation
  case weatherStation(location: CLLocation?)
}

// MARK: - Dependencies

extension FocusOnLocationSelectionAlert {
  struct Dependencies {
    let bookmarkedLocations: [WeatherInformationDTO]
    weak var selectionDelegate: FocusOnLocationSelectionAlertDelegate?
  }
}

// MARK: - Delegate

protocol FocusOnLocationSelectionAlertDelegate: class {
  func didSelectFocusOnLocationOption(_ option: FocusOnLocationOption)
}

// MARK: - Class Definition

final class FocusOnLocationSelectionAlert {
  
  // MARK: - Actions
  
  fileprivate lazy var focusOnUserLocationAction = Factory.AlertAction.make(fromType: .image(
    title: R.string.localizable.current_location(),
    image: R.image.location(),
    handler: { [dependencies] _ in
      dependencies.selectionDelegate?.didSelectFocusOnLocationOption(FocusOnLocationOption.userLocation)
    }
  ))
  fileprivate lazy var cancelAction = Factory.AlertAction.make(fromType: .cancel)
  
  // MARK: - Properties
  
  let dependencies: Dependencies
  let alertController: UIAlertController
  
  // MARK: - Initialization
  
  required init(dependencies: Dependencies) {
    self.dependencies = dependencies
    
    alertController = UIAlertController(
      title: R.string.localizable.focus_on_location().capitalized,
      message: nil,
      preferredStyle: .alert
    )
    
    let actions = dependencies.bookmarkedLocations.mapToAlertAction(dependencies: dependencies) + [focusOnUserLocationAction, cancelAction]
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
  
  func mapToAlertAction(dependencies: FocusOnLocationSelectionAlert.Dependencies) -> [UIAlertAction] {
    compactMap { weatherInformationDTO -> UIAlertAction? in
      guard let latitude = weatherInformationDTO.coordinates.latitude,
            let longitude = weatherInformationDTO.coordinates.longitude else {
        return nil
      }
      return Factory.AlertAction.make(fromType: .image(
        title: weatherInformationDTO.stationName,
        image: R.image.locateFavoriteActiveIcon(),
        handler: { [dependencies] _ in
          dependencies.selectionDelegate?.didSelectFocusOnLocationOption(FocusOnLocationOption.weatherStation(
            location: CLLocation(latitude: latitude, longitude: longitude)
          ))
        }
      ))
    }
  }
}
