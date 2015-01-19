//
//  AuthorizationStore.swift
//  FrostKit
//
//  Created by James Barrow on 19/01/2015.
//  Copyright (c) 2015 Frostlight Solutions. All rights reserved.
//

import UIKit

// TODO: Remove this class and only store 1 authorization token in the user object (when created).
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
    
    // MARK: - Adding  Authorization Tokens
    
    func createAndAddAuthorizationToken(#json: NSDictionary, requestDate: NSDate) {
        let authToken = AuthorizationToken(json: json, requestDate: requestDate)
        setObject(authToken, forKey: authToken.accessToken)
    }
    
    // MARK: - Remove  Authorization Tokens
    
    func removeAuthorizationToken(#authToken: AuthorizationToken) {
        removeObjectForKey(authToken.accessToken)
    }
    
    // MARK: - Cleanup  Authorization Tokens
    
    /**
    Remove all expired keys in the store.
    */
    func cleanup() {
        
        // TODO: Don't delete, refresh
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
