//
//  KeychainHelper.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright (c) 2014 Frostlight Solutions. All rights reserved.
//

import UIKit

public class KeychainHelper: NSObject {
    
    private class func setupSearchDirectory() -> NSMutableDictionary {
        
        let secDict = NSMutableDictionary()
        secDict.setObject(kSecClassGenericPassword, forKey: kSecClass)
        secDict.setObject(NSBundle.appName(bundle: NSBundle(forClass: KeychainHelper.self)), forKey: kSecAttrService)
        
        if let encodedIdentifier = NSBundle.appName(bundle: NSBundle(forClass: KeychainHelper.self)).dataUsingEncoding(NSUTF8StringEncoding) {
            secDict.setObject(encodedIdentifier, forKey: kSecAttrGeneric)
            secDict.setObject(encodedIdentifier, forKey: kSecAttrAccount)
        }
        
        return secDict
    }
    
    private class func searchKeychainForMatchingData() -> NSData? {
        
        let secDict = setupSearchDirectory()
        secDict.setObject(kSecMatchLimitOne, forKey: kSecMatchLimit)
        secDict.setObject(kCFBooleanTrue, forKey: kSecReturnData)
        
        var foundDict: Unmanaged<AnyObject>?
        let status = SecItemCopyMatching(secDict, &foundDict);
        
        if status == noErr {
            let opaque = foundDict?.toOpaque()
            if let op = opaque? {
                return Unmanaged<NSData>.fromOpaque(op).takeUnretainedValue()
            }
        }
        
        return nil
    }
    
    public class func setDetails(#password: String, username: String) -> Bool {
        
        let valueDict = [username: password]
        let secDict = setupSearchDirectory()
        let valueData = NSKeyedArchiver.archivedDataWithRootObject(valueDict)
        secDict.setObject(valueData, forKey: kSecValueData)
        secDict.setObject(kSecAttrAccessibleWhenUnlocked, forKey: kSecAttrAccessible)
        
        let status = SecItemAdd(secDict, nil)
        if status == noErr {
            return true
        } else if status == OSStatus(errSecDuplicateItem) {
            return updateKeychainValue(valueDict)
        }
        
        return false
    }
    
    private class func updateKeychainValue(valueDict: NSDictionary) -> Bool {
        
        let secDict = setupSearchDirectory()
        let updateDict = NSMutableDictionary()
        let valueData = NSKeyedArchiver.archivedDataWithRootObject(valueDict)
        updateDict.setObject(valueData, forKey: kSecValueData)
        
        let status = SecItemUpdate(secDict, updateDict)
        if status == OSStatus(errSecSuccess) {
            return true
        }
        
        return false
    }
    
    public class func deleteKeychain() -> Bool {
        
        let secDict = setupSearchDirectory()
        
        let status = SecItemDelete(secDict)
        if status == noErr {
            return true
        }
        
        return false
    }
    
}
