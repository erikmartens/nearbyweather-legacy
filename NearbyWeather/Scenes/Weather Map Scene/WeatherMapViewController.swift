//
//  WeatherMapViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 10.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import MapKit
import RxSwift

// MARK: - Class Definition

final class WeatherMapViewController: UIViewController, BaseViewController {
  
  typealias ViewModel = WeatherMapViewModel
  
  // MARK: - UIComponents
  
  fileprivate lazy var mapView = Factory.MapView.make(fromType: .standard(frame: view.frame))
  
  fileprivate lazy var mapTypeBarButton = Factory.BarButtonItem.make(fromType: .standard(image: R.image.layerType()))
  fileprivate lazy var focusOnLocationBarButton = Factory.BarButtonItem.make(fromType: .standard(image: R.image.marker()))
  
  fileprivate lazy var amountOfResultsBarButton10 = Factory.BarButtonItem.make(fromType: .standard(image: R.image.ten()))
  fileprivate lazy var amountOfResultsBarButton20 = Factory.BarButtonItem.make(fromType: .standard(image: R.image.twenty()))
  fileprivate lazy var amountOfResultsBarButton30 = Factory.BarButtonItem.make(fromType: .standard(image: R.image.thirty()))
  fileprivate lazy var amountOfResultsBarButton40 = Factory.BarButtonItem.make(fromType: .standard(image: R.image.forty()))
  fileprivate lazy var amountOfResultsBarButton50 = Factory.BarButtonItem.make(fromType: .standard(image: R.image.fifty()))
  
  // MARK: - Assets
  
  private let disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  let viewModel: ViewModel
  
  // MARK: - Initialization
  
  required init(dependencies: ViewModel.Dependencies) {
    viewModel = WeatherMapViewModel(dependencies: dependencies)
    super.init(nibName: nil, bundle: nil)
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
  
  // MARK: - ViewController LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel.viewDidLoad()
    setupUiLayout()
    setupBindings()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setupUiAppearance()
  }
}

// MARK: - ViewModel Bindings

extension WeatherMapViewController {
  
  func setupBindings() {
    viewModel.observeEvents()
    bindContentFromViewModel(viewModel)
    bindUserInputToViewModel(viewModel)
  }
  
  func bindContentFromViewModel(_ viewModel: ViewModel) {
    viewModel
      .mapDelegate?
      .dataSource
      .asDriver(onErrorJustReturn: nil)
      .filterNil()
      .drive(onNext: { [weak self] mapAnnotationData in
        self?.mapView.annotations.forEach { self?.mapView.removeAnnotation($0) }
        self?.mapView.addAnnotations(mapAnnotationData.annotationItems)
      })
      .disposed(by: disposeBag)
    
    viewModel
      .preferredMapTypeDriver
      .drive(onNext: { [weak mapView] mapTypeValue in
        switch mapTypeValue {
        case .standard:
          mapView?.mapType = .standard
        case .satellite:
          mapView?.mapType = .satellite
        case .hybrid:
          mapView?.mapType = .hybrid
        }
      })
      .disposed(by: disposeBag)
    
    viewModel
      .preferredAmountOfResultsDriver
      .drive(onNext: { [unowned self] amountOfResultsValue in
        switch amountOfResultsValue {
        case .ten:
          self.navigationItem.rightBarButtonItems = [self.amountOfResultsBarButton10, self.focusOnLocationBarButton]
        case .twenty:
          self.navigationItem.rightBarButtonItems = [self.amountOfResultsBarButton20, self.focusOnLocationBarButton]
        case .thirty:
          self.navigationItem.rightBarButtonItems = [self.amountOfResultsBarButton30, self.focusOnLocationBarButton]
        case .forty:
          self.navigationItem.rightBarButtonItems = [self.amountOfResultsBarButton40, self.focusOnLocationBarButton]
        case .fifty:
          self.navigationItem.rightBarButtonItems = [self.amountOfResultsBarButton50, self.focusOnLocationBarButton]
        }
      })
      .disposed(by: disposeBag)
    
    viewModel
      .focusOnWeatherStationDriver
      .drive(onNext: { [focus] location in focus(location) })
      .disposed(by: disposeBag)
    
    viewModel
      .focusOnUserLocationDriver
      .drive(onNext: { [focus] userLocation in focus(userLocation) })
      .disposed(by: disposeBag)
  }
  
  func bindUserInputToViewModel(_ viewModel: ViewModel) {
    mapTypeBarButton.rx
      .tap
      .bind(to: viewModel.onDidTapMapTypeBarButtonSubject)
      .disposed(by: disposeBag)
    
    Observable
      .merge(
        amountOfResultsBarButton10.rx.tap.asObservable(),
        amountOfResultsBarButton20.rx.tap.asObservable(),
        amountOfResultsBarButton30.rx.tap.asObservable(),
        amountOfResultsBarButton40.rx.tap.asObservable(),
        amountOfResultsBarButton50.rx.tap.asObservable()
      )
      .bind(to: viewModel.onDidTapAmountOfResultsBarButtonSubject)
      .disposed(by: disposeBag)
    
    focusOnLocationBarButton.rx
      .tap
      .bind(to: viewModel.onDidTapFocusOnLocationBarButtonSubject)
      .disposed(by: disposeBag)
  }
}

// MARK: - Setup

private extension WeatherMapViewController {
  
  func setupUiLayout() {
    navigationItem.leftBarButtonItems = [mapTypeBarButton]
    
    view.addSubview(mapView, constraints: [
      mapView.topAnchor.constraint(equalTo: view.topAnchor),
      mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ])
  }
  
  func setupUiAppearance() {
    title = R.string.localizable.tab_weatherMap()
    
    view.backgroundColor = Constants.Theme.Color.ViewElement.primaryBackground
  }
}

// MARK: - Helpers

private extension WeatherMapViewController {
  
  func focus(onLocation location: CLLocation?) {
    guard let location = location else {
      return
    }
    let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1500, longitudinalMeters: 1500)
    mapView.setRegion(region, animated: true)
  }
}
