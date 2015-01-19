//
//  AuthorizationStore.swift
//  FrostKit
//
//  Created by James Barrow on 19/01/2015.
//  Copyright (c) 2015 Frostlight Solutions. All rights reserved.
//

import UIKit

public class AuthorizationStore: NSMutableDictionary {
    
    // MARK: - Singleton
    
    /**
    Returns the shared authorization store object.
    
    :returns: The shared authorization store object.
    */
    class var shared: AuthorizationStore {
        struct Singleton {
            static let instance : AuthorizationStore = AuthorizationStore()
        }
        return Singleton.instance
    }
    
    // MARK: - Cleanup Methods
    
    /**
    Remove all expired keys in the store.
    */
    public func cleanup() {
        
        let keysToDelete = NSMutableArray()
        let selfCopy = self.mutableCopy() as NSMutableDictionary
        let timestamp = NSDate.timeIntervalSinceReferenceDate()
        for (key, value) in selfCopy {
            if let authorizationToken = value as? AuthorizationToken {
                if authorizationToken.expiresAt < timestamp {
                    keysToDelete.addObject(key)
                }
            }
        }
        removeObjectsForKeys(keysToDelete)
    }

}
