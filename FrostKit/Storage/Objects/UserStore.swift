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
    
    /// The username of the current user, or `nil` if there is none.
    public var username: String?
    /// The OAuthToken for the current user.
    private var oAuthToken: OAuthToken?
    /// Helper class variable to get the current OAuthToken.
    public class var oAuthToken: OAuthToken? {
        get { return current.oAuthToken }
        set { current.oAuthToken = newValue }
    }
    /// A dictionary of DataStores with keys of the URLs used to retrive the data.
    private lazy var contentData = Dictionary<String, DataStore>()
    /// If set to `true` then content data is manged the same as downloaded images or documents. If `false` then content data is kept indefinitely. The default is `false`.
    public var shouldManageContentData = false
    /// Returns `true` is the user is logged in and `false` if not. A user is assumed as logged in if the UserStore has a username set and details can be retrieved from the keychain wit that username.
    public var isLoggedIn: Bool {
        if let username = self.username {
            if let details = KeychainHelper.details(username: username) {
                return true
            }
        }
        return false
    }
    
    // MARK: - Singleton
    
    /**
    Returns the shared user store object.
    
    :returns: The currnet user store object.
    */
    public class var current: UserStore {
        struct Singleton {
            static let instance: UserStore = UserStore.loadUser()
        }
        return Singleton.instance
    }
    
    override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActiveNotification:", name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillResignActiveNotification:", name: UIApplicationWillResignActiveNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillResignActiveNotification, object: nil)
    }
    
    // MARK: - NSCoding Methods
    
    public required convenience init(coder aDecoder: NSCoder) {
        self.init()
        
        username = aDecoder.decodeObjectForKey("username") as? String
        oAuthToken = aDecoder.decodeObjectForKey("OAuthToken") as? OAuthToken
        if let contentData = aDecoder.decodeObjectForKey("contentData") as? [String: DataStore] {
            self.contentData = contentData
        }
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(username, forKey: "username")
        aCoder.encodeObject(oAuthToken, forKey: "OAuthToken")
        aCoder.encodeObject(contentData, forKey: "contentData")
    }
    
    // MARK: - NSNotificationCenter Methods
    
    func applicationDidBecomeActiveNotification(sender: AnyObject) {
        NSLog("applicationDidBecomeActiveNotification")
    }
    
    func applicationWillResignActiveNotification(sender: AnyObject) {
        NSLog("applicationWillResignActiveNotification")
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
    
    // MARK: - Content Data Methods
    
    /**
    Gets the data store located in the user object for a paticular url string (usually an absolute path).
    
    :param: urlString The url string to use as a key.
    
    :returns: The data store or `nil` if none if found.
    */
    public func dataStoreForURL(urlString: String) -> DataStore? {
        if shouldManageContentData == true {
            ContentManager.saveContentMetadata(absolutePath: urlString)
        }
        return contentData[urlString]
    }
    
    /**
    Sets the data store in the user object for a paticular url string (usually an absolute path).
    
    :param: dataStore The data store to set.
    :param: urlString The url string to use as a key.
    */
    public func setDataStore(dataStore: DataStore, urlString: String) {
        contentData[urlString] = dataStore
        if shouldManageContentData == true {
            ContentManager.saveContentMetadata(absolutePath: urlString)
        }
    }

}
