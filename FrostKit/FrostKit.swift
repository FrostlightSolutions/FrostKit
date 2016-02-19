//
//  FrostKit.swift
//  FrostKit
//
//  Created by James Barrow on 03/10/2014.
//  Copyright (c) 2014-2015 James Barrow - Frostlight Solutions. All rights reserved.
//

import Foundation

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#endif

// swiftlint:disable variable_name
public let FUSServiceClientUpdateSections = "com.FrostKit.FUSServiceClient.updateSections"
public let UserStoreLogoutClearData = "com.FrostKit.UserStore.logout.clearData"
public let NetworkRequestDidBeginNotification = "com.FrostKit.activityIndicator.request.begin"
public let NetworkRequestDidCompleteNotification = "com.FrostKit.activityIndicator.request.complete"
// swiftlint:enable variable_name

#if os(iOS) || os(tvOS)
internal func FKLocalizedString(key: String, comment: String = "") -> String {
    return NSLocalizedString(key, bundle: NSBundle(forClass: FrostKit.self), comment: comment)
}
#endif

public class FrostKit {
    
    // MARK: - Private Variables
    
    private var tintColor: UIColor?
    
#if os(iOS) || os(tvOS)
    private var appStoreID: String?
#endif
    
    // MARK: - Public Class Variables
    
    public class var tintColor: UIColor? {
        return FrostKit.shared.tintColor
    }
    public class func tintColor(alpha alpha: CGFloat) -> UIColor? {
        return tintColor?.colorWithAlpha(alpha)
    }
    
#if os(iOS) || os(tvOS)
    public class var appStoreID: String? {
        return FrostKit.shared.appStoreID
    }
#endif
    
    // MARK: - Singleton
    
    internal static let shared = FrostKit()
    
    init() {
#if os(iOS) || os(tvOS)
        CustomFonts.loadCustomFonts()
#endif
    }
    
    // MARK: - Setup Methods
    
    public class func setup() {
        FrostKit.shared
    }
    
    public class func setup(tintColor: UIColor) {
        FrostKit.shared.tintColor = tintColor
    }
    
#if os(iOS) || os(tvOS)
    public class func setupAppStoreID(appStoreID: String) {
        FrostKit.shared.appStoreID = appStoreID
        AppStoreHelper.shared.updateAppStoreData()
    }
#endif
    
}
