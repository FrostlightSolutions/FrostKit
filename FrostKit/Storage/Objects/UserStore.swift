//
//  UserStore.swift
//  FrostKit
//
//  Created by James Barrow on 19/01/2015.
//  Copyright (c) 2015 Frostlight Solutions. All rights reserved.
//

import UIKit

public class UserStore: NSObject, NSCoding {

    private var oAuthToken: OAuthToken?
    public class var oAuthToken: OAuthToken? {
        get { return shared.oAuthToken }
        set { shared.oAuthToken = newValue }
    }
    
    // MARK: - Singleton
    
    /**
    Returns the shared user store object.
    
    :returns: The shared user store object.
    */
    class var shared: UserStore {
        struct Singleton {
            static let instance : UserStore = UserStore.loadUser()
        }
        return Singleton.instance
    }
    
    override init() {
        super.init()
    }
    
    // MARK: - NSCoding Methods
    
    public required convenience init(coder aDecoder: NSCoder) {
        self.init()
        
        oAuthToken = aDecoder.decodeObjectForKey("OAuthToken") as? OAuthToken
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(oAuthToken, forKey: "OAuthToken")
    }
    
    // MARK: - Save / Load Methods
    
    class func saveUser() -> Bool {
        return LocalStorage.saveUserData(UserStore.shared)
    }
    
    internal class func loadUser() -> UserStore {
        if let userStore = LocalStorage.loadUserData() as? UserStore {
            return userStore
        }
        return UserStore()
    }

}
