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

final class FocusOnLocationSelectionAlertController: UIAlertController, BaseViewController {
  
  typealias ViewModel = FocusOnLocationSelectionAlertViewModel
  
  // MARK: - Actions
  
  fileprivate lazy var focusOnUserLocationAction = Factory.AlertAction.make(fromType: .image(
    title: R.string.localizable.current_location(),
    image: R.image.location(),
    handler: { [weak viewModel] _ in
      viewModel?.onDidSelectOptionSubject.onNext(.userLocation)
    }
  ))
  fileprivate lazy var cancelAction = Factory.AlertAction.make(fromType: .cancel)
  
  // MARK: - Properties
  
  let viewModel: ViewModel
  
  override var preferredStyle: UIAlertController.Style { .alert }
  
  // MARK: - Initialization
  
  required init(dependencies: ViewModel.Dependencies) {
    viewModel = FocusOnLocationSelectionAlertViewModel(dependencies: dependencies)
    
    super.init(nibName: nil, bundle: nil)
    title = R.string.localizable.focus_on_location().capitalized
    message = nil
    
    let actions = viewModel.bookmarkedLocations.mapToAlertAction(viewModel: viewModel) + [focusOnUserLocationAction, cancelAction]
    actions.forEach { addAction($0) }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    printDebugMessage(
      domain: String(describing: self),
      message: "was deinitialized",
      type: .info
    )
  }
  
  // MARK: - AlertController LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupBindings()
  }
}

// MARK: - ViewModel Bindings

extension FocusOnLocationSelectionAlertController {
  
  func setupBindings() {
    viewModel.observeEvents()
    bindContentFromViewModel(viewModel)
    bindUserInputToViewModel(viewModel)
  }
}

// MARK: - Helper Extensions

private extension Array where Element == WeatherInformationDTO {
  
  func mapToAlertAction(viewModel: FocusOnLocationSelectionAlertViewModel) -> [UIAlertAction] {
    compactMap { weatherInformationDTO -> UIAlertAction? in
      guard let latitude = weatherInformationDTO.coordinates.latitude,
            let longitude = weatherInformationDTO.coordinates.longitude else {
        return nil
      }
      return Factory.AlertAction.make(fromType: .image(
        title: weatherInformationDTO.stationName,
        image: R.image.locateFavoriteActiveIcon(),
        handler: { [weak viewModel] _ in
          viewModel?.onDidSelectOptionSubject.onNext(
            .weatherStation(location: CLLocation(latitude: latitude, longitude: longitude))
          )
        }
      ))
    }
  }
}
