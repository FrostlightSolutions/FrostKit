//
//  FrostKit.swift
//  FrostKit
//
//  Created by James Barrow on 03/10/2014.
//  Copyright (c) 2014-2015 James Barrow - Frostlight Solutions. All rights reserved.
//

import UIKit

public let FUSServiceClientUpdateSections = "com.FrostKit.FUSServiceClient.updateSections"
public let NetworkRequestDidBeginNotification = "com.FrostKit.activityIndicator.request.begin"
public let NetworkRequestDidCompleteNotification = "com.FrostKit.activityIndicator.request.complete"

internal func FKLocalizedString(key: String, comment: String = "") -> String {
    return NSLocalizedString(key, bundle: NSBundle(forClass: FrostKit.self), comment: comment)
}

public class FrostKit {
    
    public var FUSName: String?
    public var baseTintColor: UIColor?
    public var baseURLs: [String]!
    public var defaultDebugIndex = 0
    public var defaultProductionIndex = 0
    public var OAuthClientToken: String?
    public var OAuthClientSecret: String?
    
    // MARK: - Singleton
    
    internal class var shared: FrostKit {
    struct Singleton {
        static let instance : FrostKit = FrostKit()
        }
        return Singleton.instance
    }
    
    init() {
        CustomFonts.loadCustomFonts()
        UserStore.current
    }
    
    // MARK: - Setup Methods
    
    public class func setup() {
        FrostKit.shared
    }
    
    public class func setup(#FUSName: String) {
        FrostKit.shared.FUSName = FUSName
    }
    
    public class func setup(#tintColor: UIColor) {
        FrostKit.shared.baseTintColor = tintColor
    }
    
    public class func setup(#baseURLs: [String], defaultDebugIndex: Int = 0, defaultProductionIndex: Int = 0, OAuthClientToken: String? = nil, OAuthClientSecret: String? = nil) {
        FrostKit.shared.baseURLs = baseURLs
        FrostKit.shared.defaultDebugIndex = defaultDebugIndex
        FrostKit.shared.defaultProductionIndex = defaultProductionIndex
        FrostKit.shared.OAuthClientToken = OAuthClientToken
        FrostKit.shared.OAuthClientSecret = OAuthClientSecret
    }
    
    // MARK: - Custom Getter Methods
    
    public class func tintColor() -> UIColor? {
        return FrostKit.shared.baseTintColor
    }
    
}
