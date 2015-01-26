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
    
    lazy var store = Dictionary<Int, Request>()
    private var locked = false
    
    func addRequest(request: Request) {
        if locked == true {
            return
        }
        
        let identifier = request.task.taskIdentifier
        if let storedRequest = store[identifier] {
            storedRequest.cancel()
        } else {
            store[identifier] = request
        }
    }
    
    func removeRequest(request: Request) {
        let identifier = request.task.taskIdentifier
        if let storedRequest = store[identifier] {
            storedRequest.cancel()
            store.removeValueForKey(identifier)
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
