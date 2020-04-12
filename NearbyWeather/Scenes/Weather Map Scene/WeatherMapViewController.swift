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
    mapView.mapType = PreferencesDataService.shared.preferredMapType
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
  
  private func triggerFocusOnLocationAlert() {
    guard let bookmarkedWeatherDataObjects = WeatherDataManager.shared.bookmarkedWeatherDataObjects?.compactMap({
      return $0.weatherInformationDTO
    }) else {
      return
    }
    
    let alert = Factory.AlertController.make(fromType:
      .focusMapOnLocation(bookmarks: bookmarkedWeatherDataObjects,
                          completionHandler: { [weak self] weatherInformationDTO in
                            guard let weatherInformationDTO = weatherInformationDTO else {
                              self?.focusMapOnUserLocation()
                              return
                            }
                            self?.selectedBookmarkedLocation = weatherInformationDTO
                            DispatchQueue.main.async {
                              self?.focusMapOnSelectedBookmarkedLocation()
                            }
      })
    )
    present(alert, animated: true, completion: nil)
  }
  
  private func focusMapOnUserLocation() {
    if UserLocationService.shared.locationPermissionsGranted, let currentLocation = UserLocationService.shared.currentLocation {
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
    guard UserLocationService.shared.locationPermissionsGranted, UserLocationService.shared.currentLocation != nil else {
      focusMapOnSelectedBookmarkedLocation()
      return
    }
    focusMapOnUserLocation()
  }
  
  // MARK: - IBActions
  
  @IBAction func changeMapTypeButtonTapped(_ sender: UIBarButtonItem) {
    let alert = Factory.AlertController.make(fromType:
      .weatherMapType(currentMapType: PreferencesDataService.shared.preferredMapType, completionHandler: { [weak self] mapType in
        DispatchQueue.main.async {
          PreferencesDataService.shared.preferredMapType = mapType
          self?.mapView.mapType = PreferencesDataService.shared.preferredMapType
        }
      })
    )
    present(alert, animated: true, completion: nil)
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
