//
//  KeychainHelper.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright (c) 2014-2015 James Barrow - Frostlight Solutions. All rights reserved.
//

import Foundation

///
/// The keychain helper allows access to the keychain for saving passwords safely.
///
public class KeychainHelper: NSObject {
    
    private class func setupSearchDirectory() -> NSMutableDictionary {
        
        let appName = NSBundle.appName(NSBundle(forClass: KeychainHelper.self))
        
        let secDict = NSMutableDictionary()
        secDict.setObject(String(kSecClassGenericPassword), forKey: String(kSecClass))
        secDict.setObject(appName, forKey: String(kSecAttrService))
        
        if let encodedIdentifier = appName.dataUsingEncoding(NSUTF8StringEncoding) {
            secDict.setObject(encodedIdentifier, forKey: String(kSecAttrGeneric))
            secDict.setObject(encodedIdentifier, forKey: String(kSecAttrAccount))
        }
        
        return secDict
    }
    
    private class func searchKeychainForMatchingData() -> NSData? {
        
        let secDict = setupSearchDirectory()
        secDict.setObject(String(kSecMatchLimitOne), forKey: String(kSecMatchLimit))
        secDict.setObject(NSNumber(bool: true), forKey: String(kSecReturnData))
        // kCFBooleanTrue
        
        var foundDict: AnyObject?
        let status = SecItemCopyMatching(secDict, &foundDict);
        
        if status == noErr {
            return foundDict as? NSData
        } else {
            let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
            NSLog("ERROR: Search Keychain for Data: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    /**
    Gets the details saved for a paticular username.
    
    - parameter username: The username of the details to return.
    
    - returns: The details saved with the username if found, otherwise `nil`.
    */
    public class func details(username username: String) -> AnyObject? {
        
        let valueData = searchKeychainForMatchingData()
        if let data = valueData {
            
            let valueDict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSDictionary
            if let dict = valueDict {
                return dict.objectForKey(username)
            }
        }
        
        return nil
    }
    
    /**
    Set details for a username to the keychain.
    
    - parameter details:  The details to save.
    - parameter username: The username to reference the details with.
    
    - returns: Returns `true` if the details were successfully saved, `false` if not.
    */
    public class func setDetails(details details: AnyObject, username: String) -> Bool {
        
        let valueDict = [username: details]
        let secDict = setupSearchDirectory()
        let valueData = NSKeyedArchiver.archivedDataWithRootObject(valueDict)
        secDict.setObject(valueData, forKey: String(kSecValueData))
        secDict.setObject(String(kSecAttrAccessibleWhenUnlocked), forKey: String(kSecAttrAccessible))
        
        let status = SecItemAdd(secDict, nil)
        if status == noErr {
            return true
        } else {
            if status == OSStatus(errSecDuplicateItem) {
                return updateKeychainValue(valueDict)
            } else {
                let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
                NSLog("ERROR: Set Keychain Details: \(error.localizedDescription)")
            }
        }
        
        return false
    }
    
    private class func updateKeychainValue(valueDict: NSDictionary) -> Bool {
        
        let secDict = setupSearchDirectory()
        let updateDict = NSMutableDictionary()
        let valueData = NSKeyedArchiver.archivedDataWithRootObject(valueDict)
        updateDict.setObject(valueData, forKey: String(kSecValueData))
        
        let status = SecItemUpdate(secDict, updateDict)
        if status == OSStatus(errSecSuccess) {
            return true
        } else {
            let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
            NSLog("ERROR: Update Keychain Details: \(error.localizedDescription)")
        }
        
        return false
    }
    
    /**
    Deletes the currently saved keychain.
    
    - returns: Returns `true` if deletion has succeeded or `false` if it failed.
    */
    public class func deleteKeychain() -> Bool {
        
        let secDict = setupSearchDirectory()
        
        let status = SecItemDelete(secDict)
        if status == noErr {
            return true
        } else {
            let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
            NSLog("ERROR: Delete Keychain Details: \(error.localizedDescription)")
        }
        
        return false
    }
    
}
