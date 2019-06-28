//
//  FrostKit.swift
//  FrostKit
//
//  Created by James Barrow on 03/10/2014.
//  Copyright © 2014 - 2017 James Barrow - Frostlight Solutions. All rights reserved.
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

@available(iOS, deprecated: 13.0, message: "This is no longer needed as of iOS 13 as the network indicator has been deprecated. This class will be removed in v2.0.0 of FrostKit.")
public let NetworkRequestDidBeginNotification = "com.FrostKit.activityIndicator.request.begin"
@available(iOS, deprecated: 13.0, message: "This is no longer needed as of iOS 13 as the network indicator has been deprecated. This class will be removed in v2.0.0 of FrostKit.")
public let NetworkRequestDidCompleteNotification = "com.FrostKit.activityIndicator.request.complete"
// swiftlint:enable variable_name

internal func FKLocalizedString(_ key: String, comment: String = "") -> String {
    return NSLocalizedString(key, bundle: Bundle(for: FrostKit.self), comment: comment)
}

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
    
    public class func tintColor(with alpha: CGFloat) -> Color? {
        return tintColor?.color(with: alpha)
    }
    
#if os(iOS) || os(tvOS) || os(OSX)
    public class var appStoreID: String? {
        return FrostKit.shared.appStoreID
    }
#endif
    
    // MARK: - Singleton
    
    internal static let shared = FrostKit()
    
    internal init() {
#if os(iOS) || os(tvOS) || os(OSX)
        CustomFonts.loadCustomFonts()
#endif
    }
    
    // MARK: - Setup Methods
    
    public class func setup(tintColor: Color? = nil, appStoreID: String? = nil) {
        
        let frostKit = FrostKit.shared
        
        if let tintColor = tintColor {
            frostKit.tintColor = tintColor
        }
        
#if os(iOS) || os(tvOS) || os(OSX)
        if let appStoreID = appStoreID {
            frostKit.appStoreID = appStoreID
            AppStoreHelper.shared.updateAppStoreData()
        }
#endif
    }
}
