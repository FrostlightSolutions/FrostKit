//
//  RequestStore.swift
//  FrostKit
//
//  Created by James Barrow on 26/01/2015.
//  Copyright (c) 2015 Frostlight Solutions. All rights reserved.
//

import UIKit
import Alamofire

public class RequestStore: NSObject {
    
    lazy var store = Dictionary<String, Request>()
    private var locked = false
    
    func addRequest(request: Request, urlString: String) {
        if locked == true {
            return
        }
        
        if let storedRequest = store[urlString] {
            storedRequest.cancel()
        }
        
        store[urlString] = request
    }
    
    func removeRequestFor(urlString: String) {
        if let storedRequest = store[urlString] {
            storedRequest.cancel()
            store.removeValueForKey(urlString)
        }
    }
    
    func cancelAllTasks() {
        locked = true
        for (key, request) in store {
            request.cancel()
        }
        locked = false
    }
    
}
