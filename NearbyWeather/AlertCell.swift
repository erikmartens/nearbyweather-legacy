//
//  AlertCell.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 14.04.17.
//  Copyright © 2017 Erik Maximilian Martens. All rights reserved.
//

import UIKit

class AlertCell: UITableViewCell {
    
    private var timer: Timer?
    
    @IBOutlet weak var backgroundColorView: UIView!
    @IBOutlet weak var warningImageView: UIView!
    @IBOutlet weak var noticeLabel: UILabel!
    
    deinit {
        warningImageView.layer.removeAllAnimations()
        timer?.invalidate()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        warningImageView.layer.removeAllAnimations()
        timer?.invalidate()
    }
    
    func configureWithErrorDataDTO(_ errorDataDTO: ErrorDataDTO?) {
        backgroundColorView.layer.cornerRadius = 5.0
        backgroundColorView.layer.backgroundColor = UIColor.black.cgColor
        
        if let errorDataDTO = errorDataDTO {
            switch errorDataDTO.errorType.value {
            case .httpError:
                let errorCode = errorDataDTO.httpStatusCode ?? -1
                noticeLabel.text = String(format: NSLocalizedString("http_error", comment: ""), "\(errorCode)")
            case .requestTimOutError:
                noticeLabel.text = NSLocalizedString("request_timeout_error", comment: "")
            case .malformedUrlError:
                noticeLabel.text = NSLocalizedString("malformed_url_error", comment: "")
            case .unparsableResponseError:
                noticeLabel.text = NSLocalizedString("unreadable_result_error", comment: "")
            case .jsonSerializationError:
                noticeLabel.text = NSLocalizedString("LocationsListTVC_UnreadableResult", comment: "")
            case .unrecognizedApiKeyError:
                noticeLabel.text = NSLocalizedString("unauthorized_api_key_error", comment: "")
            case .locationUnavailableError:
                noticeLabel.text = NSLocalizedString("location_unavailable_error", comment: "")
            case .locationAccessDenied:
               noticeLabel.text =  NSLocalizedString("location_denied_error", comment: "")
            }
        } else {
            noticeLabel.text = NSLocalizedString("unknown_error", comment: "")
        }
        startAnimationTimer()
    }
    
    private func startAnimationTimer() {
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(AlertCell.animateWarningShake), userInfo: nil, repeats: false)
    }
    
    @objc private func animateWarningShake() {
        warningImageView.layer.removeAllAnimations()
        warningImageView.animatePulse(withAnimationDelegate: self)
    }
}

extension AlertCell: CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        startAnimationTimer()
    }
}
