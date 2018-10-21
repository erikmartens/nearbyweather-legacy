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
    
    private (set) static var isRegisteredForRemoteNotifications = false
    private var badgePermissionsCompletion: BoolCompletion?
    
    // MARK: - Instantiation
    
    public static func instantiateSharedInstance() {
        shared = PermissionsManager()
    }
    
    // MARK: - Interface
    
    public var areBadgesApproved: Bool {
        guard let settings = UIApplication.shared.currentUserNotificationSettings, settings.types.contains(UIUserNotificationType.badge) else {
            return false
        }
        return true
    }
    
    public func didRegisterForRemoteNotifications(success: Bool) {
        PermissionsManager.isRegisteredForRemoteNotifications = success
        guard success else {
            callBadgePermissionsCompletion(withSuccess: false)
            return
        }
        guard UserDefaults.standard.bool(forKey: kAskedForNotificationsPermissionKey) else { return }
        callBadgePermissionsCompletion(withSuccess: areBadgesApproved)
    }
    
    public func didRegisterNotificationSettings(_ settings: UIUserNotificationSettings) {
        UserDefaults.standard.set(true, forKey: kAskedForNotificationsPermissionKey)
        callBadgePermissionsCompletion(withSuccess: settings.types.contains(UIUserNotificationType.badge))
    }
    
    public func checkBadgePermissions(withCompletion completion: @escaping BoolCompletion) {
        badgePermissionsCompletion = completion
        UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: UIUserNotificationType.badge, categories: nil))
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    private func callBadgePermissionsCompletion(withSuccess success: Bool) {
        guard let completion = badgePermissionsCompletion else { return }
        self.badgePermissionsCompletion = nil
        completion(success)
    }
}
