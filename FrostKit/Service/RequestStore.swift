//
//  RequestStore.swift
//  FrostKit
//
//  Created by James Barrow on 26/01/2015.
//  Copyright © 2015-Current James Barrow - Frostlight Solutions. All rights reserved.
//

import Foundation

/// 
/// The request store keeps track of all requests passed into it. It stops duplicate requests being called by canceling any already running requests passed to it, until they are done and removed.
/// 
/// It will however be able to differentuate between different page requests, and so not cancel a page `n` request if page `n+1` is also requested.
///
public class RequestStore {
    
    /// The store to hold references to the requests being managed.
    private lazy var store = Dictionary<String, NSURLSessionTask>()
    /// Describes if the store is locked `true` or not `false`. This is set to `false` by default and is only locked when canceling all tasks.
    private var locked = false
    
    /**
    Add a rquest to the store with a url string (normally absolute is sugested) to use as the key to store the request under in the store.
    
    - parameter request: The request to store and manage.
    - parameter urlString: The url string to use as the key.
    */
    public func addRequest(request: NSURLSessionTask, urlString: String) {
        if locked == true {
            return
        }
        
        if store[urlString] != nil {
            request.cancel()
        } else {
            store[urlString] = request
        }
    }
    
    /**
    Remove a request using a url string (normally absolute is sugested) as the key.
    
    - parameter urlString: The url string to use as the key of the request to remove.
    */
    public func remove(requestWithURL urlString: String) {
        if let storedRequest = store[urlString] {
            storedRequest.cancel()
            store.removeValue(forKey: urlString)
        }
    }
    
    /**
    Cancel all tasks currently in the store. This function will lock the store as it cancels all it's content, stopping any new requests to be added.
    */
    public func cancelAllTasks() {
        locked = true
        for (_, request) in store {
            request.cancel()
        }
        locked = false
    }
    
    /**
    Checks to see if there is a rquest in the store that matches the passed in url string.
    
    - parameter urlString: The url string to check for.
    
    - returns: If a matching request is found then `true` is returned, otherwise `false` is returned.
    */
    public func contains(requestWithURL urlString: String) -> Bool {
        let containsRequest = store[urlString] != nil
        return containsRequest
    }
    
}
