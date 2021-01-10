//
//  WeatherMapAnnotationView.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 10.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import MapKit
import RxSwift

// MARK: - Definitions

private extension WeatherMapAnnotationView {
  struct Definitions {
    static let backgroundColorViewLeadingInset: CGFloat = 48
    static let mainContentStackViewTopBottomInset: CGFloat = 20
    static let mainContentStackViewTrailingInset: CGFloat = 40
    static let weatherConditionSymbolHeight: CGFloat = 80
    static let conditionDetailSymbolHeightWidth: CGFloat = 15
  }
}

// MARK: - Class Definition

final class WeatherMapAnnotationView: MKAnnotationView, BaseAnnotationView {
  
  typealias AnnotationViewModel = WeatherMapAnnotationViewModel
  
  // MARK: - UIComponents
  
  private lazy var backgroundColorView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = Constants.Dimensions.Size.CornerRadiusSize.from(weight: .medium)
    return view
  }()
  
  private lazy var mainContentStackView = Factory.StackView.make(fromType: .vertical(distribution: .fillEqually, spacing: Constants.Dimensions.Spacing.InterElementSpacing.xDistance(from: .medium)))
  private lazy var lineOneStackView = Factory.StackView.make(fromType: .horizontal(distribution: .fillEqually, spacing: Constants.Dimensions.Spacing.InterElementSpacing.xDistance(from: .medium)))
  private lazy var lineTwoStackView = Factory.StackView.make(fromType: .horizontal(distribution: .fillEqually, spacing: Constants.Dimensions.Spacing.InterElementSpacing.xDistance(from: .medium)))
  
  private lazy var temperatureStackView = Factory.StackView.make(fromType: .horizontal(distribution: .fillProportionally, spacing: Constants.Dimensions.Spacing.InterElementSpacing.xDistance(from: .small)))
  private lazy var cloudCoverageStackView = Factory.StackView.make(fromType: .horizontal(distribution: .fillProportionally, spacing: Constants.Dimensions.Spacing.InterElementSpacing.xDistance(from: .small)))
  private lazy var humidityStackView = Factory.StackView.make(fromType: .horizontal(distribution: .fillProportionally, spacing: Constants.Dimensions.Spacing.InterElementSpacing.xDistance(from: .small)))
  private lazy var windspeedStackView = Factory.StackView.make(fromType: .horizontal(distribution: .fillProportionally, spacing: Constants.Dimensions.Spacing.InterElementSpacing.xDistance(from: .small)))
  
  private lazy var weatherConditionSymbolLabel = Factory.Label.make(fromType: .weatherSymbol)
  private lazy var placeNameLabel = Factory.Label.make(fromType: .title(numberOfLines: 1))
  private lazy var temperatureSymbolImageView = Factory.ImageView.make(fromType: .symbol(image: R.image.temperature()))
  private lazy var temperatureLabel = Factory.Label.make(fromType: .body(numberOfLines: 1))
  private lazy var cloudCoverageSymbolImageView = Factory.ImageView.make(fromType: .symbol(image: R.image.cloudCoverFilled()))
  private lazy var cloudCoverageLabel = Factory.Label.make(fromType: .body(alignment: .right, numberOfLines: 1))
  private lazy var humiditySymbolImageView = Factory.ImageView.make(fromType: .symbol(image: R.image.humidity()))
  private lazy var humidityLabel = Factory.Label.make(fromType: .body(numberOfLines: 1))
  private lazy var windspeedSymbolImageView = Factory.ImageView.make(fromType: .symbol(image: R.image.windSpeed()))
  private lazy var windspeedLabel = Factory.Label.make(fromType: .body(alignment: .right, numberOfLines: 1))
  
  // MARK: - Assets
  
  private var disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  var annotationViewModel: AnnotationViewModel?
  
  // MARK: - Initialization
  
  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    layoutUserInterface()
    setupAppearance()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Cell Life Cycle
  
  func configure(with annotationViewModel: BaseAnnotationViewModelProtocol?) {
    guard let annotationViewModel = annotationViewModel as? WeatherMapAnnotationViewModel else {
      return
    }
    self.annotationViewModel = annotationViewModel
    bindInputFromViewModel(annotationViewModel)
    bindOutputToViewModel(annotationViewModel)
  }
}

// MARK: - ViewModel Bindings

extension WeatherMapAnnotationView {
  
  internal func bindInputFromViewModel(_ annotationViewModel: AnnotationViewModel) {
    annotationViewModel.annotationModelDriver
      .drive(onNext: { [setContent] in setContent($0) })
      .disposed(by: disposeBag)
  }
  
  internal func bindOutputToViewModel(_ annotationViewModel: AnnotationViewModel) {} // nothing to do
}

// MARK: - Cell Composition

private extension WeatherMapAnnotationView {
  
  func setContent(for annotationModel: WeatherMapAnnotationModel) {
  }
  
  func layoutUserInterface() {
    
  }
  
  func setupAppearance() {
    backgroundColor = .clear
  }
}
