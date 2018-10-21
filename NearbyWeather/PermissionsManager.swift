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
    
    // MARK: - Types
    
    typealias BoolCompletion = ((Bool) -> ())
    
    // MARK: - Properties
    
    public static var shared: PermissionsManager!
    private var areNotificationsAsyncApproved = false
    private var badgePermissionsCompletion: BoolCompletion?
    
    // MARK: - Instantiation
    
    public static func instantiateSharedInstance() {
        shared = PermissionsManager()
    }
    
    // MARK: - Interface
    
    public var areNotificationsApproved: Bool {
        if #available(iOS 10.0, *) {
            return areNotificationsAsyncApproved
        }
        
        guard
            let settings = UIApplication.shared.currentUserNotificationSettings,
            settings.types.contains(UIUserNotificationType.badge),
            settings.types.contains(UIUserNotificationType.alert)
        else {
            return false
        }
        return true
    }
    
    func areNotificationsApproved(withCompletion completion: @escaping BoolCompletion) {
        guard #available(iOS 10.0, *) else {
            completion(false)
            return
        }
        
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional:
                    let areApproved = settings.badgeSetting == .enabled && settings.alertSetting == .enabled
                    self?.areNotificationsAsyncApproved = areApproved
                    completion(areApproved)
                case .notDetermined, .denied:
                    self?.areNotificationsAsyncApproved = false
                    completion(false)
                }
            }
        }
    }
    
    public func didRegisterForRemoteNotifications(success: Bool) {
        guard success else {
            callBadgePermissionsCompletion(withSuccess: false)
            return
        }
        guard UserDefaults.standard.bool(forKey: kAskedForNotificationsPermissionKey) else { return }
        callBadgePermissionsCompletion(withSuccess: areNotificationsApproved)
    }
    
    public func didRegisterNotificationSettings(_ settings: UIUserNotificationSettings) {
        UserDefaults.standard.set(true, forKey: kAskedForNotificationsPermissionKey)
        callBadgePermissionsCompletion(withSuccess: settings.types.contains(UIUserNotificationType.badge))
    }
    
    public func checkNotificationsPermissions(withCompletion completion: @escaping BoolCompletion) {
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] (granted, error) in
                DispatchQueue.main.async {
                    guard error == nil else {
                        self?.areNotificationsAsyncApproved = false
                        completion(false)
                        return
                    }
                    
                    self?.areNotificationsAsyncApproved = granted
                    if granted {
                        completion(true)
                        UIApplication.shared.registerForRemoteNotifications()
                    } else {
                        completion(false)
                    }
                }
            }
        } else {
            badgePermissionsCompletion = completion
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .alert, .sound], categories: nil))
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    private func callBadgePermissionsCompletion(withSuccess success: Bool) {
        guard let completion = badgePermissionsCompletion else { return }
        self.badgePermissionsCompletion = nil
        completion(success)
    }
}
