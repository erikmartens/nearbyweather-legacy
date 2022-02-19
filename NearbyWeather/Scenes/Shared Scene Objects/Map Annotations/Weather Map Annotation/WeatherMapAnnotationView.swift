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
    static let margin: CGFloat = 4
    static let width: CGFloat = 110
    static let height: CGFloat = 50
    static let triangleHeight: CGFloat = 10
    static let radius: CGFloat = 10
    static let borderWidth: CGFloat = 4
    static let titleLabelFontSize: CGFloat = 12
    static let subtitleLabelFontSize: CGFloat = 10
  }
}

// MARK: - Class Definition

final class WeatherMapAnnotationView: MKAnnotationView, BaseAnnotationView {
  
  typealias AnnotationViewModel = WeatherMapAnnotationViewModel
  
  // MARK: - UIComponents
  
  private lazy var circleLayer = Factory.ShapeLayer.make(fromType: .circle(radius: Definitions.radius, borderWidth: Definitions.borderWidth))
  private lazy var speechBubbleLayer = Factory.ShapeLayer.make(fromType: .speechBubble(
    size: CGSize(width: Definitions.width, height: Definitions.height),
    radius: Definitions.radius,
    borderWidth: Definitions.borderWidth,
    margin: Definitions.margin,
    triangleHeight: Definitions.triangleHeight
  ))
  
  private lazy var titleLabel = Factory.Label.make(fromType: .mapAnnotation(
    fontSize: Definitions.titleLabelFontSize,
    width: Definitions.width - 2*Definitions.margin,
    height: (Definitions.height - 2*Definitions.margin - Definitions.triangleHeight)/2,
    yOffset: -Definitions.height/2
  ))
  
  private lazy var subtitleLabel = Factory.Label.make(fromType: .mapAnnotation(
    fontSize: Definitions.subtitleLabelFontSize,
    width: Definitions.width - 2*Definitions.margin,
    height: (Definitions.height - 2*Definitions.margin - Definitions.triangleHeight)/2,
    yOffset: -Definitions.height/2
  ))
  
  private lazy var tapGestureRecognizer = UITapGestureRecognizer()
  
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
    annotationViewModel.observeEvents()
    bindContentFromViewModel(annotationViewModel)
    bindUserInputToViewModel(annotationViewModel)
  }
}

// MARK: - ViewModel Bindings

extension WeatherMapAnnotationView {
  
  func bindContentFromViewModel(_ annotationViewModel: AnnotationViewModel) {
    annotationViewModel.annotationModelDriver
      .drive(onNext: { [setContent] in setContent($0) })
      .disposed(by: disposeBag)
  }
  
  func bindUserInputToViewModel(_ annotationViewModel: WeatherMapAnnotationViewModel) {
    tapGestureRecognizer.rx
      .event
      .bind { _ in annotationViewModel.onDidTapAnnotationView.onNext(()) }
      .disposed(by: disposeBag)
  }
}

// MARK: - Annotation Composition

private extension WeatherMapAnnotationView {
  
  func setContent(for annotationModel: WeatherMapAnnotationModel) {
    circleLayer.fillColor = annotationModel.backgroundColor?.cgColor
    circleLayer.strokeColor = annotationModel.borderColor?.cgColor
    
    speechBubbleLayer.fillColor = annotationModel.backgroundColor?.cgColor
    speechBubbleLayer.strokeColor = annotationModel.borderColor?.cgColor
    
    titleLabel.text = annotationModel.title
    titleLabel.textColor = annotationModel.borderColor
    
    subtitleLabel.text = annotationModel.subtitle
    subtitleLabel.textColor = annotationModel.borderColor
  }
  
  func layoutUserInterface() {
    circleLayer.bounds.origin = CGPoint(x: -frame.width/2 + Definitions.radius, y: -frame.height/2 + Definitions.radius)
    layer.addSublayer(circleLayer)
    
    speechBubbleLayer.position = .zero
    layer.addSublayer(speechBubbleLayer)

    titleLabel.center = CGPoint(x: frame.size.width/2, y: titleLabel.frame.size.height/2 + Definitions.margin)
    addSubview(titleLabel)

    subtitleLabel.center = CGPoint(x: frame.size.width/2, y: titleLabel.frame.size.height/2 + Definitions.margin + titleLabel.frame.size.height)
    addSubview(subtitleLabel)
    
    addGestureRecognizer(tapGestureRecognizer)
  }
  
  func setupAppearance() {
    clipsToBounds = false
    backgroundColor = .clear
  }
}
