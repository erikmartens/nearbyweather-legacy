//
//  PermissionsManager.swift
//  NearbyWeather
//
//  Created by Lukas Prokein on 20/10/2018.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

final class PermissionsManager {
    
    // MARK: - Properties
    
    public static var shared: PermissionsManager!
    private var notificationPermissionsRequestCompletion: ((Bool) -> ())?
    
    // MARK: - Instantiation
    
    public static func instantiateSharedInstance() {
        shared = PermissionsManager()
    }
    
    // MARK: - Interface
    
    public func requestNotificationPermissions(with completion: @escaping ((Bool) -> ())) {
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                DispatchQueue.main.async {
                    guard error == nil, granted else {
                        completion(false)
                        return
                    }
                    
                    UNUserNotificationCenter.current().getNotificationSettings { settings in
                        DispatchQueue.main.async {
                            switch settings.authorizationStatus {
                            case .authorized, .provisional:
                                let areApproved = settings.badgeSetting == .enabled && settings.alertSetting == .enabled
                                completion(areApproved)
                            case .notDetermined, .denied:
                                completion(false)
                            }
                        }
                    }
                }
            }
        } else {
            guard let settings = UIApplication.shared.currentUserNotificationSettings,
                settings.types.contains(UIUserNotificationType.badge),
                settings.types.contains(UIUserNotificationType.alert) else {
                    notificationPermissionsRequestCompletion = completion
                    UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .alert, .sound], categories: nil))
                    return
            }
            completion(true)
        }
    }
    
    public func didRegisterNotificationSettings(_ settings: UIUserNotificationSettings) {
        callBadgePermissionsCompletion(withSuccess: settings.types.contains(UIUserNotificationType.badge))
    }
    
    private func callBadgePermissionsCompletion(withSuccess success: Bool) {
        guard let completion = notificationPermissionsRequestCompletion else { return }
        self.notificationPermissionsRequestCompletion = nil
        completion(success)
    }
}
