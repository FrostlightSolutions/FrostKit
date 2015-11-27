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
    /// The OAuthToken for the current user. A `username` mas ALWAYS be set before the OAuth token is.
    internal var oAuthToken: OAuthToken? {
        didSet {
            updateKeychain()
        }
    }
    /// An array of section dictionaries returned by FUS.
    public lazy var sections = Array<[String: String]>()
    /// A dictionary of DataStores with keys of the URLs used to retrive the data.
    private lazy var contentData = Dictionary<String, DataStore>()
    /// If set to `true` then content data is manged the same as downloaded images or documents. If `false` then content data is kept indefinitely. The default is `false`.
    public var shouldManageContentData = false
    /// A dictionary of custom data to be stored in the user store. This will be saved and stored with the user object.
    public var customDataStore = Dictionary<String, AnyObject>()
    /// Returns `true` is the user is logged in and `false` if not. A user is assumed as logged in if the UserStore has a username set and details can be retrieved from the keychain wit that username.
    public var isLoggedIn: Bool {
        if let username = self.username where KeychainHelper.details(username: username) != nil {
            return true
        }
        return false
    }
    private var saving = false
    
    // MARK: - Singleton
    
    /**
    Returns the shared user store object.
    
    - returns: The currnet user store object.
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
    
    public required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        
        if let username = aDecoder.decodeObjectForKey("username") as? String {
            self.username = username
            oAuthToken = KeychainHelper.details(username: username) as? OAuthToken
        }
        if let sections = aDecoder.decodeObjectForKey("sections") as? [[String: String]] {
            self.sections = sections
        }
        if let contentData = aDecoder.decodeObjectForKey("contentData") as? [String: DataStore] {
            self.contentData = contentData
        }
        
        if let customDataStore = aDecoder.decodeObjectForKey("customDataStore") as? [String: AnyObject] {
            self.customDataStore = customDataStore
        }
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(username, forKey: "username")
        aCoder.encodeObject(sections, forKey: "sections")
        aCoder.encodeObject(contentData, forKey: "contentData")
        aCoder.encodeObject(customDataStore, forKey: "customDataStore")
    }
    
    // MARK: - NSNotificationCenter Methods
    
    func applicationDidBecomeActiveNotification(sender: AnyObject) {
        
    }
    
    func applicationWillResignActiveNotification(sender: AnyObject) {
        UserStore.saveUser()
    }
    
    // MARK: - Save / Load Methods
    
    /**
    Updates the keychain with the current OAuth token. If the OAuth token and a username is present, then the keychain is updated. If not, it is deleted.
    */
    private func updateKeychain() {
        if oAuthToken != nil && username != nil {
            KeychainHelper.setDetails(details: oAuthToken!, username: username!)
        } else {
            KeychainHelper.deleteKeychain()
        }
    }
    
    /**
    Saves the current UserStore shared instance.
    
    - returns: `true` if the save completed successfully, `false` if it failed.
    */
    public class func saveUser(completed: ((Bool) -> Void)? = nil) {
        
        if UserStore.current.saving == false {
            UserStore.current.saving = true
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                let success = LocalStorage.saveUserData(UserStore.current)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    UserStore.current.saving = false
                    completed?(success)
                })
            })
        }
    }
    
    /**
    Loads the UserStore object from local storage if available. If there is no previously saved item, it creates a new one.
    
    - returns: A loaded or newly created UserStore object.
    */
    internal class func loadUser() -> UserStore {
        if let userStore = LocalStorage.loadUserData() as? UserStore {
            return userStore
        }
        return UserStore()
    }
    
    // MARK: - Logout and Reset Methods
    
    /**
    Logs out and resets the current user.
    */
    public class func logoutCurrentUser() {
        UserStore.current.resetUser()
        UserStore.saveUser { (success) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName(UserStoreLogoutClearData, object: nil)
        }
    }
    
    /**
    Resets all the user stores data to nil and empties the content data.
    */
    private func resetUser() {
        username = nil
        oAuthToken = nil
        sections.removeAll(keepCapacity: true)
        contentData.removeAll(keepCapacity: true)
        customDataStore.removeAll(keepCapacity: true)
    }
    
    // MARK: - Content Data Methods
    
    /**
    Gets the data store located in the user object for a paticular url string (usually an absolute path).
    
    - parameter urlString: The url string to use as a key.
    
    - returns: The data store or `nil` if none if found.
    */
    public func dataStoreForURL(urlString: String) -> DataStore? {
        if shouldManageContentData == true {
            ContentManager.saveContentMetadata(absolutePath: urlString)
        }
        return contentData[urlString]
    }
    
    /**
    Sets the data store in the user object for a paticular url string (usually an absolute path).
    
    - parameter dataStore: The data store to set.
    - parameter urlString: The url string to use as a key.
    */
    public func setDataStore(dataStore: DataStore, urlString: String) {
        contentData[urlString] = dataStore
        if shouldManageContentData == true {
            ContentManager.saveContentMetadata(absolutePath: urlString)
        }
    }
    
    // MARK: - Sections Search Methods
    
    /**
    Searches the sections array for a section dictionary with a certain key. Return `nil` if no section dictionary is found.
    
    - parameter key: The key of the section dictionary to search for.
    
    - returns: A section dictionary or `nil` if none is found.
    */
    public func searchForSectionWithKey(key:String) -> [String: String]? {
        if sections.count > 0 {
            let filter = NSPredicate(format: "%K == %@", "key", key)
            let filteredSections = (sections as NSArray).filteredArrayUsingPredicate(filter)
            return filteredSections.first as? [String: String]
        }
        return nil
    }

}
