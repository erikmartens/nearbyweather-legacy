//
//  NearbyLocationsMapViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 22.01.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import MapKit

final class WeatherMapViewController: UIViewController {
  
  // MARK: - Routing
  
  weak var stepper: WeatherMapStepper?
  
  // MARK: - IBOutlets
  
  @IBOutlet weak var mapView: MKMapView!
  
  @IBOutlet weak var changeMapTypeButton: UIBarButtonItem!
  @IBOutlet weak var focusLocationButton: UIBarButtonItem!
  
  // MARK: - Properties
  
  var weatherLocationMapAnnotations: [WeatherLocationMapAnnotation]!
  
  private var selectedBookmarkedLocation: WeatherInformationDTO?
  private var previousRegion: MKCoordinateRegion?
  
  // MARK: - ViewController Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBar.styleStandard()
    
    mapView.delegate = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    selectedBookmarkedLocation = WeatherDataManager.shared.bookmarkedWeatherDataObjects?.first?.weatherInformationDTO
    
    prepareMapAnnotations()
    focusOnAvailableLocation()
  }
  
  // MARK: - Private Helpers
  
  private func prepareMapAnnotations() {
    weatherLocationMapAnnotations = [WeatherLocationMapAnnotation]()
    
    let bookmarkedLocationAnnotations: [WeatherLocationMapAnnotation]? = WeatherDataManager.shared.bookmarkedWeatherDataObjects?.compactMap {
      guard let weatherDTO = $0.weatherInformationDTO else { return nil }
      return WeatherLocationMapAnnotation(weatherDTO: weatherDTO)
    }
    weatherLocationMapAnnotations.append(contentsOf: bookmarkedLocationAnnotations ?? [WeatherLocationMapAnnotation]())
    
    let nearbyocationAnnotations = WeatherDataManager.shared.nearbyWeatherDataObject?.weatherInformationDTOs?.compactMap {
      return WeatherLocationMapAnnotation(weatherDTO: $0)
    }
    weatherLocationMapAnnotations.append(contentsOf: nearbyocationAnnotations ?? [WeatherLocationMapAnnotation]())
    
    mapView.addAnnotations(weatherLocationMapAnnotations)
  }
  
  private func triggerMapTypeAlert() {
    let mapTypes: [MKMapType] = [.standard, .satellite, .hybrid]
    let mapTypeTitles: [MKMapType: String] = [.standard: R.string.localizable.map_type_standard(),
                                              .satellite: R.string.localizable.map_type_satellite(),
                                              .hybrid: R.string.localizable.map_type_hybrid()]
    
    let optionsAlert = UIAlertController(title: R.string.localizable.select_map_type().capitalized, message: nil, preferredStyle: .alert)
    mapTypes.forEach { mapTypeCase in
      let action = UIAlertAction(title: mapTypeTitles[mapTypeCase], style: .default, handler: { _ in
        DispatchQueue.main.async {
          self.mapView.mapType = mapTypeCase
        }
      })
      if mapTypeCase == self.mapView.mapType {
        action.setValue(true, forKey: "checked")
      }
      optionsAlert.addAction(action)
    }
    let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .cancel, handler: nil)
    optionsAlert.addAction(cancelAction)
    
    present(optionsAlert, animated: true, completion: nil)
  }
  
  private func triggerFocusOnLocationAlert() {
    let optionsAlert: UIAlertController = UIAlertController(title: R.string.localizable.focus_on_location(), message: nil, preferredStyle: .alert)
    
    guard let bookmarkedWeatherDataObjects = WeatherDataManager.shared.bookmarkedWeatherDataObjects?.compactMap({
      return $0.weatherInformationDTO
    }) else {
      return
    }
    
    bookmarkedWeatherDataObjects.forEach { weatherInformationDTO in
      let action = UIAlertAction(title: weatherInformationDTO.cityName, style: .default, handler: { _ in
        self.selectedBookmarkedLocation = weatherInformationDTO
        DispatchQueue.main.async {
          self.focusMapOnSelectedBookmarkedLocation()
        }
      })
      action.setValue(R.image.locateFavoriteActiveIcon(), forKey: Constants.Keys.KeyValueBindings.kImage)
      optionsAlert.addAction(action)
    }
    
    let currentLocationAction = UIAlertAction(title: R.string.localizable.current_location(), style: .default, handler: { _ in
      DispatchQueue.main.async {
        self.focusMapOnUserLocation()
      }
    })
    currentLocationAction.setValue(R.image.locateUserActiveIcon(), forKey: Constants.Keys.KeyValueBindings.kImage)
    optionsAlert.addAction(currentLocationAction)
    
    let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .cancel, handler: nil)
    optionsAlert.addAction(cancelAction)
    
    present(optionsAlert, animated: true, completion: nil)
  }
  
  private func focusMapOnUserLocation() {
    if LocationService.shared.locationPermissionsGranted, let currentLocation = LocationService.shared.currentLocation {
      let region = MKCoordinateRegion.init(center: currentLocation.coordinate, latitudinalMeters: 15000, longitudinalMeters: 15000)
      mapView.setRegion(region, animated: true)
    }
  }
  
  private func focusMapOnSelectedBookmarkedLocation() {
    guard let selectedLocation = selectedBookmarkedLocation else {
      return
    }
    let coordinate = CLLocationCoordinate2D(latitude: selectedLocation.coordinates.latitude, longitude: selectedLocation.coordinates.longitude)
    let region = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: 15000, longitudinalMeters: 15000)
    mapView.setRegion(region, animated: true)
  }
  
  private func focusOnAvailableLocation() {
    if let previousRegion = previousRegion {
      mapView.setRegion(previousRegion, animated: true)
      return
    }
    guard LocationService.shared.locationPermissionsGranted, LocationService.shared.currentLocation != nil else {
      focusMapOnSelectedBookmarkedLocation()
      return
    }
    focusMapOnUserLocation()
  }
  
  // MARK: - IBActions
  
  @IBAction func changeMapTypeButtonTapped(_ sender: UIBarButtonItem) {
    triggerMapTypeAlert()
  }
  
  @IBAction func focusLocationButtonTapped(_ sender: UIBarButtonItem) {
    triggerFocusOnLocationAlert()
  }
}

extension WeatherMapViewController: MKMapViewDelegate {
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard let annotation = annotation as? WeatherLocationMapAnnotation else {
      return nil
    }
    
    var viewForCurrentAnnotation: WeatherLocationMapAnnotationView?
    if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.Keys.MapAnnotation.kMapAnnotationViewIdentifier) as? WeatherLocationMapAnnotationView {
      viewForCurrentAnnotation = dequeuedAnnotationView
    } else {
      viewForCurrentAnnotation = WeatherLocationMapAnnotationView(frame: kMapAnnotationViewInitialFrame)
    }
    viewForCurrentAnnotation?.annotation = annotation
    viewForCurrentAnnotation?.configure(
      withTitle: annotation.title ?? Constants.Messages.kNotSet,
      subtitle: annotation.subtitle ?? Constants.Messages.kNotSet,
      fillColor: (annotation.isDayTime ?? true) ? Constants.Theme.BrandColors.standardDay : Constants.Theme.BrandColors.standardNight,
      tapHandler: { [weak self] _ in
        self?.previousRegion = mapView.region
        self?.stepper?.requestRouting(toStep:
          WeatherMapStep.weatherDetails(identifier: annotation.locationId)
        )
      }
    )
    return viewForCurrentAnnotation
  }
}
