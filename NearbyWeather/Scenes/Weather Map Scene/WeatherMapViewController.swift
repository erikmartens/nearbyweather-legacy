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
  
  fileprivate lazy var mapTypeBarButton = Factory.BarButtonItem.make(fromType: .systemImageWithCircle(imageName: "globe"))
  fileprivate lazy var focusOnLocationBarButton = Factory.BarButtonItem.make(fromType: .systemImageWithCircle(imageName: "location.fill"))
  
  fileprivate lazy var amountOfResultsBarButton10 = Factory.BarButtonItem.make(fromType: .systemImageWithCircle(
    imageName: "10.circle.fill",
    paletteColors: [Constants.Theme.Color.MarqueColors.standardMarque, .clear]
  ))
  fileprivate lazy var amountOfResultsBarButton20 = Factory.BarButtonItem.make(fromType: .systemImageWithCircle(
    imageName: "20.circle.fill",
    paletteColors: [Constants.Theme.Color.MarqueColors.standardMarque, .clear]
  ))
  fileprivate lazy var amountOfResultsBarButton30 = Factory.BarButtonItem.make(fromType: .systemImageWithCircle(
    imageName: "30.circle.fill",
    paletteColors: [Constants.Theme.Color.MarqueColors.standardMarque, .clear]
  ))
  fileprivate lazy var amountOfResultsBarButton40 = Factory.BarButtonItem.make(fromType: .systemImageWithCircle(
    imageName: "40.circle.fill",
    paletteColors: [Constants.Theme.Color.MarqueColors.standardMarque, .clear]
  ))
  fileprivate lazy var amountOfResultsBarButton50 = Factory.BarButtonItem.make(fromType: .systemImageWithCircle(
    imageName: "50.circle.fill",
    paletteColors: [Constants.Theme.Color.MarqueColors.standardMarque, .clear]
  ))
  
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
    viewModel.viewWillAppear()
    setupUiAppearance()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    viewModel.viewWillDisappear()
  }
}

// MARK: - ViewModel Bindings

extension WeatherMapViewController {
  
  func setupBindings() {
    mapView.delegate = viewModel.mapDelegate
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
      .drive(onNext: { [unowned mapView] mapAnnotationData in
        mapView.annotations.forEach { mapView.removeAnnotation($0) }
        mapView.addAnnotations(mapAnnotationData.annotationItems)
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
          self.navigationItem.rightBarButtonItems = [amountOfResultsBarButton10, focusOnLocationBarButton]
        case .twenty:
          self.navigationItem.rightBarButtonItems = [amountOfResultsBarButton20, focusOnLocationBarButton]
        case .thirty:
          self.navigationItem.rightBarButtonItems = [amountOfResultsBarButton30, focusOnLocationBarButton]
        case .forty:
          self.navigationItem.rightBarButtonItems = [amountOfResultsBarButton40, focusOnLocationBarButton]
        case .fifty:
          self.navigationItem.rightBarButtonItems = [amountOfResultsBarButton50, focusOnLocationBarButton]
        }
      })
      .disposed(by: disposeBag)
    
    viewModel
      .focusOnWeatherStationDriver
      .drive(onNext: { [weak mapView] location in mapView?.focus(onCoordinate: location?.coordinate, animated: true) })
      .disposed(by: disposeBag)
    
    viewModel
      .focusOnUserLocationDriver
      .drive(onNext: { [weak mapView] userLocation in mapView?.focus(onCoordinate: userLocation?.coordinate, latitudinalMeters: 20000, longitudinalMeters: 20000, animated: true) })
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
    
    tabBarController?.tabBar.isTranslucent = false
    navigationController?.navigationBar.isTranslucent = false
    navigationController?.view.backgroundColor = Constants.Theme.Color.ViewElement.secondaryBackground
    view.backgroundColor = Constants.Theme.Color.ViewElement.secondaryBackground
  }
}
