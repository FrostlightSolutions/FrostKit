//
//  RequestStore.swift
//  FrostKit
//
//  Created by James Barrow on 26/01/2015.
//  Copyright (c) 2015 Frostlight Solutions. All rights reserved.
//

import UIKit
import Alamofire

/// 
/// The request store keeps track of all requests passed into it. It stops duplicate requests being called by canceling any already running requests passed to it, until they are done and removed.
/// 
/// It will however be able to differentuate between different page requests, and so not cancel a page 'n' request if page 'n+1' is also requested.
///
public class RequestStore: NSObject {
    
    /// The store to hold references to the requests being managed.
    lazy var store = Dictionary<String, Request>()
    /// Describes if the store is locked `true` or not `false`. This is set to `false` by default and is only locked when canceling all tasks.
    private var locked = false
    
    /**
    Add a rquest to the store with a router object to ditermine the key.
    
    :param: request The request to store and manage.
    :param: router  The router to determine the key.
    */
    func addRequest(request: Request, router: Router) {
        addRequest(request, urlString: router.URLRequest.URL.absoluteString!)
    }
    
    /**
    Add a rquest to the store with a url string (normally absolute is sugested) to use as the key to store the request under in the store.
    
    :param: request The request to store and manage.
    :param: urlString The url string to use as the key.
    */
    func addRequest(request: Request, urlString: String) {
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
    Remove a request using a router object to ditermine the key.
    
    :param: router The router to determine the key of the request to remove.
    */
    func removeRequestFor(#router: Router) {
        removeRequestFor(urlString: router.URLRequest.URL.absoluteString!)
    }
    
    /**
    Remove a request using a url string (normally absolute is sugested) as the key.
    
    :param: router The url string to use as the key of the request to remove.
    */
    func removeRequestFor(#urlString: String) {
        if let storedRequest = store[urlString] {
            storedRequest.cancel()
            store.removeValueForKey(urlString)
        }
    }
    
    /**
    Cancel all tasks currently in the store. This function will lock the store as it cancels all it's content, stopping any new requests to be added.
    */
    func cancelAllTasks() {
        locked = true
        for (key, request) in store {
            request.cancel()
        }
        locked = false
    }
    
}
