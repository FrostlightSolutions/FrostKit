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
#elseif os(OSX)
import AppKit
#endif

#if os(OSX)
public typealias Color = NSColor
#else
public typealias Color = UIColor
#endif

#if os(OSX)
public typealias Font = NSFont
#else
public typealias Font = UIFont
#endif

// swiftlint:disable variable_name
public let FUSServiceClientUpdateSections = "com.FrostKit.FUSServiceClient.updateSections"
public let UserStoreLogoutClearData = "com.FrostKit.UserStore.logout.clearData"
public let NetworkRequestDidBeginNotification = "com.FrostKit.activityIndicator.request.begin"
public let NetworkRequestDidCompleteNotification = "com.FrostKit.activityIndicator.request.complete"
// swiftlint:enable variable_name

#if os(iOS) || os(tvOS) || os(OSX)
internal func FKLocalizedString(key: String, comment: String = "") -> String {
    return NSLocalizedString(key, bundle: Bundle(for: FrostKit.self), comment: comment)
}
#endif

public class FrostKit {
    
    // MARK: - Private Variables
    private var tintColor: Color?
    
#if os(iOS) || os(tvOS) || os(OSX)
    private var appStoreID: String?
#endif
    
    // MARK: - Public Class Variables
    
    public class var tintColor: Color? {
        return FrostKit.shared.tintColor
    }
    public class func tintColor(alpha: CGFloat) -> Color? {
        return tintColor?.color(withAlpha: alpha)
    }
    
#if os(iOS) || os(tvOS) || os(OSX)
    public class var appStoreID: String? {
        return FrostKit.shared.appStoreID
    }
#endif
    
    // MARK: - Singleton
    
    internal static let shared = FrostKit()
    
    init() {
#if os(iOS) || os(tvOS) || os(OSX)
        CustomFonts.loadCustomFonts()
#endif
    }
    
    // MARK: - Setup Methods
    
    public class func setup() {
        let _ = FrostKit.shared
    }
    
    public class func setup(tintColor: Color) {
        FrostKit.shared.tintColor = tintColor
    }
    
#if os(iOS) || os(tvOS) || os(OSX)
    public class func setupAppStoreID(appStoreID: String) {
        FrostKit.shared.appStoreID = appStoreID
        AppStoreHelper.shared.updateAppStoreData()
    }
#endif
    
}
