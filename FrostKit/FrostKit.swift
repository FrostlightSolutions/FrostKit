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


public let FUSServiceClientUpdateSections = "com.FrostKit.FUSServiceClient.updateSections"
public let UserStoreLogoutClearData = "com.FrostKit.UserStore.logout.clearData"
public let NetworkRequestDidBeginNotification = "com.FrostKit.activityIndicator.request.begin"
public let NetworkRequestDidCompleteNotification = "com.FrostKit.activityIndicator.request.complete"

#if os(iOS) || os(tvOS)
internal func FKLocalizedString(key: String, comment: String = "") -> String {
    return NSLocalizedString(key, bundle: NSBundle(forClass: FrostKit.self), comment: comment)
}
#endif

public class FrostKit {
    
    // MARK: - Private Variables
    
    private var tintColor: UIColor?
#if os(iOS)
    private var FUSName: String?
    private lazy var baseURLs = Array<String>()
    private var defaultDebugIndex = 0
    private var defaultProductionIndex = 0
    private var OAuthClientID: String?
    private var OAuthClientSecret: String?
#endif
    
    // MARK: - Public Class Variables
    
    public class var tintColor: UIColor? {
        return FrostKit.shared.tintColor
    }
    public class func tintColor(alpha alpha: CGFloat) -> UIColor? {
        return tintColor?.colorWithAlpha(alpha)
    }
#if os(iOS)
    public class var FUSName: String? {
        return FrostKit.shared.FUSName
    }
    public class var baseURLs: [String] {
        return FrostKit.shared.baseURLs
    }
    public class var defaultDebugIndex: Int {
        return FrostKit.shared.defaultDebugIndex
    }
    public class var defaultProductionIndex: Int {
        return FrostKit.shared.defaultProductionIndex
    }
    public class var OAuthClientID: String? {
        return FrostKit.shared.OAuthClientID
    }
    public class var OAuthClientSecret: String? {
        return FrostKit.shared.OAuthClientSecret
    }
#endif
    
    // MARK: - Singleton
    
    internal class var shared: FrostKit {
        struct Singleton {
            static let instance : FrostKit = FrostKit()
        }
        return Singleton.instance
    }
    
    init() {
#if os(iOS) || os(tvOS)
        CustomFonts.loadCustomFonts()
#endif

#if os(iOS)
        UserStore.current
#endif
    }
    
    // MARK: - Setup Methods
    
    public class func setup() {
        FrostKit.shared
    }
    
    public class func setup(tintColor: UIColor) {
        FrostKit.shared.tintColor = tintColor
    }
    
#if os(iOS)
    public class func setupFUSName(FUSName: String) {
        FrostKit.shared.FUSName = FUSName
    }
    
    public class func setupURLs(baseURLs: [String], defaultDebugIndex: Int = 0, defaultProductionIndex: Int = 0, OAuthClientID: String? = nil, OAuthClientSecret: String? = nil) {
        FrostKit.shared.baseURLs = baseURLs
        FrostKit.shared.defaultDebugIndex = defaultDebugIndex
        FrostKit.shared.defaultProductionIndex = defaultProductionIndex
        FrostKit.shared.OAuthClientID = OAuthClientID
        FrostKit.shared.OAuthClientSecret = OAuthClientSecret
    }
#endif
    
}
