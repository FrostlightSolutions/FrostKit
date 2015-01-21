//
//  OAuthToken.swift
//  FrostKit
//
//  Created by James Barrow on 19/01/2015.
//  Copyright (c) 2015 Frostlight Solutions. All rights reserved.
//

import UIKit

public class OAuthToken: NSObject, NSCoding, NSCopying {
    
    /// The `access_token` returned from FUS.
    lazy var accessToken = ""
    /// The `refresh_token` returned from FUS.
    lazy var refreshToken = ""
    /// The timestamp the token will expire atcalculated from the `expires_in` number added to the timestamp of the date-time the request was sent.
    lazy var expiresAt: NSTimeInterval = 0
    /// A date value created from `expiresAt`.
    var expiresAtDate: NSDate {
        return NSDate(timeIntervalSinceReferenceDate: expiresAt)
    }
    /// A boolian value stating if the token has expired.
    var expired: Bool {
        return NSDate.timeIntervalSinceReferenceDate() > expiresAt
    }
    /// The `token_type` returned from FUS.
    lazy var tokenType = ""
    /// The `scope` returned from FUS.
    lazy var scope = ""
    
    override init() {
        super.init()
    }
    
    /**
    Convenience init to allow creating a `OAuthToken` from anouther `OAuthToken`.
    
    :param: oAuthToken The `OAuthToken` to take values from.
    */
    convenience init(oAuthToken: OAuthToken) {
        self.init()
        
        self.accessToken = oAuthToken.accessToken
        self.refreshToken = oAuthToken.refreshToken
        self.expiresAt = oAuthToken.expiresAt
        self.tokenType = oAuthToken.tokenType
        self.scope = oAuthToken.scope
    }
    
    /**
    Convenience init to allow creating a `OAuthToken` from an `NSDictionary` JSON.
    
    :param: json        `NSDictionary` of the JSON to parse into the `OAuthToken`.
    :param: requestDate The date the token was requested.
    */
    convenience init(json: NSDictionary, requestDate: NSDate = NSDate()) {
        self.init()
        
        if let accessToken = json["access_token"] as? String {
            self.accessToken = accessToken
        }
        
        if let refreshToken = json["refresh_token"] as? String {
            self.refreshToken = refreshToken
        }
        
        if let expiresIn = json["expires_in"] as? Int {
            self.expiresAt = requestDate.timeIntervalSinceReferenceDate + NSTimeInterval(expiresIn)
        }
        
        if let tokenType = json["token_type"] as? String {
            self.tokenType = tokenType
        }
        
        if let scope = json["scope"] as? String {
            self.scope = scope
        }
    }
    
    // MARK: - NSCoding Methods
    
    public required convenience init(coder aDecoder: NSCoder) {
        self.init()
        
        accessToken = aDecoder.decodeObjectForKey("access_token") as String
        refreshToken = aDecoder.decodeObjectForKey("refresh_token") as String
        expiresAt = aDecoder.decodeDoubleForKey("expires_at")
        tokenType = aDecoder.decodeObjectForKey("token_type") as String
        scope = aDecoder.decodeObjectForKey("scope") as String
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(accessToken, forKey: "access_token")
        aCoder.encodeObject(refreshToken, forKey: "refresh_token")
        aCoder.encodeDouble(expiresAt, forKey: "expires_at")
        aCoder.encodeObject(tokenType, forKey: "token_type")
        aCoder.encodeObject(scope, forKey: "scope")
    }
    
    // MARK: - NSCopying Methods
    
    public func copyWithZone(zone: NSZone) -> AnyObject {
        return OAuthToken(oAuthToken: self)
    }
    
}
