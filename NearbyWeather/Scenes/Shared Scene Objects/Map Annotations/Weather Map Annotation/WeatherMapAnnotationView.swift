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
    static let height: CGFloat = 72
    static let triangleHeight: CGFloat = 10
    static let radius: CGFloat = 10
    static let borderWidth: CGFloat = 4
    
    static let labelWidth: CGFloat = Definitions.width - 2*Definitions.margin
    static let labelHeight: CGFloat = (Definitions.height - 2*Definitions.margin - Definitions.triangleHeight)/3
    static let weatherConditionSymbolImageViewWidthHeight: CGFloat = labelHeight
    
    static var titleLabelFontSize: CGFloat {
      switch UIApplication.shared.preferredContentSizeCategory {
      case .accessibilityExtraLarge, .accessibilityExtraExtraLarge, .accessibilityExtraExtraExtraLarge:
        return 18
      case .accessibilityMedium, .accessibilityLarge, .extraExtraExtraLarge:
        return 16
      case .large, .extraLarge, .extraExtraLarge:
        return 14
      case .small, .medium:
        return 12
      case .extraSmall:
        return 10
      case .unspecified:
        return 12
      default:
        return 12
      }
    }
    
    static var subtitleLabelFontSize: CGFloat {
      switch UIApplication.shared.preferredContentSizeCategory {
      case .accessibilityExtraLarge, .accessibilityExtraExtraLarge, .accessibilityExtraExtraExtraLarge:
        return 16
      case .accessibilityMedium, .accessibilityLarge, .extraExtraExtraLarge:
        return 14
      case .large, .extraLarge, .extraExtraLarge:
        return 12
      case .small, .medium:
        return 10
      case .extraSmall:
        return 8
      case .unspecified:
        return 12
      default:
        return 12
      }
    }
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
  
  private lazy var titleLabel = Factory.Label.make(fromType: .mapAnnotationTitle(
    fontSize: Definitions.titleLabelFontSize,
    width: Definitions.labelWidth,
    height: Definitions.labelHeight
  ))
  
  private lazy var weatherConditionSymbolImageView = Factory.ImageView.make(fromType: .weatherConditionSymbol)
  private lazy var subtitleLabel = Factory.Label.make(fromType: .mapAnnotationSubtitle(
    fontSize: Definitions.subtitleLabelFontSize,
    width: Definitions.labelWidth - Definitions.weatherConditionSymbolImageViewWidthHeight - Definitions.margin,
    height: Definitions.labelHeight
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
  
  override func prepareForDisplay() {
    super.prepareForDisplay()
    annotationViewModel?.observeEvents()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    disposeBag = DisposeBag()
  }
  
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
    circleLayer.strokeColor = annotationModel.tintColor?.cgColor
    
    speechBubbleLayer.fillColor = annotationModel.backgroundColor?.cgColor
    speechBubbleLayer.strokeColor = annotationModel.tintColor?.cgColor
    
    titleLabel.text = annotationModel.title
    titleLabel.textColor = annotationModel.tintColor
    
    subtitleLabel.text = annotationModel.subtitle
    subtitleLabel.textColor = annotationModel.tintColor
    
    weatherConditionSymbolImageView.image = annotationModel.weatherConditionSymbol
  }
  
  func layoutUserInterface() {
    // set frame
    frame = CGRect(origin: .zero, size: CGSize(width: Definitions.width, height: Definitions.height))
    
    // add UI components
    circleLayer.bounds.origin = CGPoint(x: -frame.width/2 + Definitions.radius, y: -frame.height/2 + Definitions.radius)
    layer.addSublayer(circleLayer)

    layer.addSublayer(speechBubbleLayer)
    
    // weather condition
    weatherConditionSymbolImageView.frame = CGRect(
      x: 0,
      y: 0,
      width: Definitions.weatherConditionSymbolImageViewWidthHeight,
      height: Definitions.weatherConditionSymbolImageViewWidthHeight
    )
    weatherConditionSymbolImageView.center = CGPoint(
      x: frame.size.width/2,
      y: 3*Definitions.margin - 2*Definitions.labelHeight
    )
    addSubview(weatherConditionSymbolImageView)
    
    // title
    titleLabel.center = CGPoint(
      x: frame.size.width/2,
      y: 3*Definitions.margin - Definitions.labelHeight
    )
    addSubview(titleLabel)
    
    // subtitle
    subtitleLabel.center = CGPoint(
      x: frame.size.width/2,
      y: 3*Definitions.margin
    )
    addSubview(subtitleLabel)
    
    // add interaction components
    addGestureRecognizer(tapGestureRecognizer)
  }
  
  func setupAppearance() {
    clipsToBounds = false
    backgroundColor = .clear
  }
}
