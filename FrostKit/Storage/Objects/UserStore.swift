//
//  UserStore.swift
//  FrostKit
//
//  Created by James Barrow on 19/01/2015.
//  Copyright (c) 2015 Frostlight Solutions. All rights reserved.
//

import UIKit

/// 
/// This object contains all to shared data corisponding to the currently logged in user.
///
/// This object should be deleted or cleared on a user logging out.
///
public class UserStore: NSObject, NSCoding {

    private var oAuthToken: OAuthToken?
    /// Helper class variable to get the current OAuthToken.
    public class var oAuthToken: OAuthToken? {
        get { return current.oAuthToken }
        set { current.oAuthToken = newValue }
    }
    
    // MARK: - Singleton
    
    /**
    Returns the shared user store object.
    
    :returns: The currnet user store object.
    */
    class var current: UserStore {
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
    
    /**
    Saves the current UserStore shared instance.
    
    :returns: `true` if the save completed successfully, `false` if it failed.
    */
    class func saveUser() -> Bool {
        return LocalStorage.saveUserData(UserStore.current)
    }
    
    /**
    Loads the UserStore object from local storage if available. If there is no previously saved item, it creates a new one.
    
    :returns: A loaded or newly created UserStore object.
    */
    internal class func loadUser() -> UserStore {
        if let userStore = LocalStorage.loadUserData() as? UserStore {
            return userStore
        }
        return UserStore()
    }

}
