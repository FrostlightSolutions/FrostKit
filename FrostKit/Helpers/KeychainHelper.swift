//
//  KeychainHelper.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright © 2014 - 2017 James Barrow - Frostlight Solutions. All rights reserved.
//

import Foundation

///
/// The keychain helper allows access to the keychain for saving passwords safely.
///
public class KeychainHelper {
    
    private class func setupSearchDirectory() -> NSMutableDictionary {
        
        let appName = Bundle.appName(Bundle(for: KeychainHelper.self))
        
        let secDict = NSMutableDictionary()
        secDict.setObject(kSecClassGenericPassword, forKey: kSecClass as! NSCopying)
        secDict.setObject(appName, forKey: kSecAttrService as! NSCopying)
        
        if let encodedIdentifier = appName.data(using: String.Encoding.utf8) {
            secDict.setObject(encodedIdentifier, forKey: kSecAttrGeneric as! NSCopying)
            secDict.setObject(encodedIdentifier, forKey: kSecAttrAccount as! NSCopying)
        }
        
        return secDict
    }
    
    private class func searchKeychainForMatchingData() -> Data? {
        
        let secDict = setupSearchDirectory()
        secDict.setObject(kSecMatchLimitOne, forKey: kSecMatchLimit as! NSCopying)
        secDict.setObject(NSNumber(value: true), forKey: kSecReturnData as! NSCopying)
        // kCFBooleanTrue
        
        var foundDict: CFTypeRef?
        let status = SecItemCopyMatching(secDict, &foundDict)
        
        if status == noErr {
            return foundDict as? Data
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
    public class func details(username: String) -> Any? {
        
        let valueData = searchKeychainForMatchingData()
        if let data = valueData {
            
            let valueDict = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSDictionary
            if let dict = valueDict {
                return dict.object(forKey: username)
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
    public class func set(details: Any, username: String) -> Bool {
        
        let valueDict = [username: details]
        let secDict = setupSearchDirectory()
        let valueData = NSKeyedArchiver.archivedData(withRootObject: valueDict)
        secDict.setObject(valueData, forKey: kSecValueData as! NSCopying)
        secDict.setObject(kSecAttrAccessibleWhenUnlocked, forKey: kSecAttrAccessible as! NSCopying)
        
        let status = SecItemAdd(secDict, nil)
        if status == noErr {
            return true
        } else {
            if status == OSStatus(errSecDuplicateItem) {
                return KeychainHelper.update(valueDict as NSDictionary)
            } else {
                let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
                NSLog("ERROR: Set Keychain Details: \(error.localizedDescription)")
            }
        }
        
        return false
    }
    
    private class func update(_ valueDict: NSDictionary) -> Bool {
        
        let secDict = setupSearchDirectory()
        let updateDict = NSMutableDictionary()
        let valueData = NSKeyedArchiver.archivedData(withRootObject: valueDict)
        updateDict.setObject(valueData, forKey: kSecValueData as! NSCopying)
        
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
