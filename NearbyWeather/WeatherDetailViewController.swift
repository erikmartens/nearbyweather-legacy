//
//  WeatherDetailViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.02.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import MapKit

private let kMapAnnotationIdentifier = "de.nearbyWeather.weatherDetailView.mkAnnotation"

class WeatherDetailViewController: UIViewController {
    
    static func instantiateFromStoryBoard(withTitle title: String, weatherDTO: OWMWeatherDTO) -> WeatherDetailViewController {
        let viewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "WeatherDetailViewController") as! WeatherDetailViewController
        viewController.titleString = title
        viewController.weatherDTO = weatherDTO
        return viewController
    }
    
    
    // MARK: - Properties
    
    /* Injected */
    
    private var titleString: String!
    private var weatherDTO: OWMWeatherDTO!
    
    /* Outlets */
    
    @IBOutlet weak var conditionSymbolLabel: UILabel!
    @IBOutlet weak var conditionNameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet var separatorLineHeightConstraints: [NSLayoutConstraint]!
    
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = titleString
        mapView.delegate = self
        
        configureMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configure()
    }
    
    
    // MARK: - Private Helpers
    
    private func configure() {
        navigationController?.navigationBar.styleStandard(withTransluscency: false, animated: true)
        navigationController?.navigationBar.addDropShadow(offSet: CGSize(width: 0, height: 1), radius: 10)
        
        separatorLineHeightConstraints.forEach { $0.constant = 1/UIScreen.main.scale }
        
        let weatherCode = weatherDTO.weatherCondition[0].identifier
        conditionSymbolLabel.text = ConversionService.weatherConditionSymbol(fromWeathercode: weatherCode)
        
        conditionNameLabel.text = weatherDTO.weatherCondition.first?.conditionName
        
        let temperatureUnit = WeatherDataService.shared.temperatureUnit
        let temperatureKelvin = weatherDTO.atmosphericInformation.temperatureKelvin
        temperatureLabel.text = "🌡 \(ConversionService.temperatureDescriptor(forTemperatureUnit: temperatureUnit, fromRawTemperature: temperatureKelvin))"
        
        if LocationService.shared.locationPermissionsGranted, let userLocation = LocationService.shared.location {
            let location = CLLocation(latitude: weatherDTO.coordinates.latitude, longitude: weatherDTO.coordinates.longitude)
            let distanceInMetres = location.distance(from: userLocation)
            
            let distanceSpeedUnit = WeatherDataService.shared.windspeedUnit
            let distanceString = ConversionService.distanceDescriptor(forDistanceSpeedUnit: distanceSpeedUnit, forDistanceInMetres: distanceInMetres)
            
            distanceLabel.text = String(format: NSLocalizedString("WeatherDetailVC_DistanceFrom", comment: ""), distanceString)
        } else {
            distanceLabel.isHidden = true
        }
    }
    
    private func configureMap() {
        mapView.layer.cornerRadius = 10
        
        let mapAnnotation = WeatherLocationMapAnnotation(weatherDTO: weatherDTO)
        mapView.addAnnotation(mapAnnotation)
        
        let location = CLLocation(latitude: weatherDTO.coordinates.latitude, longitude: weatherDTO.coordinates.longitude)
        let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 5000, 5000)
        mapView.setRegion(region, animated: false)
    }
}

extension WeatherDetailViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? WeatherLocationMapAnnotation else {
            return nil
        }
        
        if #available(iOS 11, *) {
            var viewForCurrentAnnotation: MKMarkerAnnotationView?
            if let dequeuedAnnotation = mapView.dequeueReusableAnnotationView(withIdentifier: kMapAnnotationIdentifier) as? MKMarkerAnnotationView {
                dequeuedAnnotation.annotation = annotation
                viewForCurrentAnnotation = dequeuedAnnotation
            } else {
                viewForCurrentAnnotation = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: kMapAnnotationIdentifier)
                viewForCurrentAnnotation?.canShowCallout = true
                viewForCurrentAnnotation?.calloutOffset = CGPoint(x: -5, y: 5)
            }
            return viewForCurrentAnnotation
        } else {
            var viewForCurrentAnnotation: MKAnnotationView?
            if let dequeuedAnnotation = mapView.dequeueReusableAnnotationView(withIdentifier: kMapAnnotationIdentifier) {
                dequeuedAnnotation.annotation = annotation
                viewForCurrentAnnotation = dequeuedAnnotation
            } else {
                viewForCurrentAnnotation = MKAnnotationView(annotation: annotation, reuseIdentifier: kMapAnnotationIdentifier)
                viewForCurrentAnnotation?.canShowCallout = true
                viewForCurrentAnnotation?.calloutOffset = CGPoint(x: -5, y: 5)
            }
            return viewForCurrentAnnotation
        }
    }
}
