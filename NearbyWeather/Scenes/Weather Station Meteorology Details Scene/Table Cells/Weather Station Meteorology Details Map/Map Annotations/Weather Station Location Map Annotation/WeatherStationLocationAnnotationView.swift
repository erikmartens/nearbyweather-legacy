//
//  WeatherStationLocationAnnotationView.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 01.04.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import MapKit
import RxSwift

// MARK: - Definitions

private extension WeatherStationLocationAnnotationView {
  struct Definitions {
    static let margin: CGFloat = 4
    static let width: CGFloat = 48
    static let height: CGFloat = 56
    static let triangleHeight: CGFloat = 10
    static let radius: CGFloat = 10
    static let borderWidth: CGFloat = 4
    
    static let stationSymbolImageViewWidthHeight: CGFloat = Definitions.height - 6*Definitions.margin - Definitions.triangleHeight
  }
}

// MARK: - Class Definition

final class WeatherStationLocationAnnotationView: MKAnnotationView, BaseAnnotationView {
  
  typealias AnnotationViewModel = WeatherStationLocationMapAnnotationViewModel
  
  // MARK: - UIComponents
  
  private lazy var circleLayer = Factory.ShapeLayer.make(fromType: .circle(radius: Definitions.radius, borderWidth: Definitions.borderWidth))
  private lazy var speechBubbleLayer = Factory.ShapeLayer.make(fromType: .speechBubble(
    size: CGSize(width: Definitions.width, height: Definitions.height),
    radius: Definitions.radius,
    borderWidth: Definitions.borderWidth,
    margin: Definitions.margin,
    triangleHeight: Definitions.triangleHeight
  ))
  
  private lazy var stationSymbolImageView = Factory.ImageView.make(fromType: .weatherConditionSymbol)
  
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
  
  override func prepareForDisplay() {
    super.prepareForDisplay()
    annotationViewModel?.observeEvents()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    disposeBag = DisposeBag()
  }
  
  func configure(with annotationViewModel: BaseAnnotationViewModelProtocol?) {
    guard let annotationViewModel = annotationViewModel as? WeatherStationLocationMapAnnotationViewModel else {
      return
    }
    self.annotationViewModel = annotationViewModel
    annotationViewModel.observeEvents()
    bindContentFromViewModel(annotationViewModel)
    bindUserInputToViewModel(annotationViewModel)
  }
}

// MARK: - ViewModel Bindings

extension WeatherStationLocationAnnotationView {
  
  func bindContentFromViewModel(_ annotationViewModel: AnnotationViewModel) {
    annotationViewModel.annotationModelDriver
      .drive(onNext: { [setContent] in setContent($0) })
      .disposed(by: disposeBag)
  }
  
  func bindUserInputToViewModel(_ annotationViewModel: AnnotationViewModel) {
    // nothing to do
  }
}

// MARK: - Annotation Composition

private extension WeatherStationLocationAnnotationView {
  
  func setContent(for annotationModel: WeatherStationLocationAnnotationModel) {
    circleLayer.fillColor = annotationModel.backgroundColor?.cgColor
    circleLayer.strokeColor = annotationModel.tintColor?.cgColor
    
    speechBubbleLayer.fillColor = annotationModel.backgroundColor?.cgColor
    speechBubbleLayer.strokeColor = annotationModel.tintColor?.cgColor
    
    stationSymbolImageView.image = annotationModel.stationSymbol
  }
  
  func layoutUserInterface() {
    // set frame
    frame = CGRect(origin: .zero, size: CGSize(width: Definitions.width, height: Definitions.height))
    
    // add UI components
    circleLayer.bounds.origin = CGPoint(x: -frame.width/2 + Definitions.radius, y: -frame.height/2 + Definitions.radius)
    layer.addSublayer(circleLayer)

    layer.addSublayer(speechBubbleLayer)
    
    // station symbol image
    stationSymbolImageView.frame = CGRect(
      x: 0,
      y: 0,
      width: Definitions.stationSymbolImageViewWidthHeight,
      height: Definitions.stationSymbolImageViewWidthHeight
    )
    stationSymbolImageView.center = CGPoint(
      x: frame.size.width/2,
      y: -Definitions.margin
    )
    addSubview(stationSymbolImageView)
  }
  
  func setupAppearance() {
    clipsToBounds = false
    backgroundColor = .clear
  }
}
