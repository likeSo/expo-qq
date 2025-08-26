//
//  AppLifecycleDelegate.swift
//  ExpoQQ
//
//  Created by Aron on 2025/7/28.
//

import Foundation
import ExpoModulesCore


public class AppLifecycleDelegate: ExpoAppDelegateSubscriber {
    public func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if TencentOAuth.canHandleOpen(url) {
            return TencentOAuth.handleOpen(url)
        }
        return true
    }
    
    public func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([any UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                if TencentOAuth.canHandleUniversalLink(url) {
                    return TencentOAuth.handleUniversalLink(url)
                }
            }
        }
        return true
    }
}
