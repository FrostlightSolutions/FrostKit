//
//  RequestStoreTests.swift
//  FrostKit
//
//  Created by James Barrow on 18/06/2016.
//  Copyright © 2016-Current James Barrow - Frostlight Solutions. All rights reserved.
//

import XCTest
@testable import FrostKit

class RequestStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRequestStoreAdd() {
        
        let store = RequestStore()
        
        let urlString = "https://httpbin.org/get"
        let task = URLSession.shared().dataTask(with: URL(string: urlString)!)
        store.addRequest(request: task, urlString: urlString)
        
        if store.containsRequestWithURL(urlString) {
            XCTAssert(true, "Task added to the store.")
        } else {
            XCTAssert(false, "Task not added to the store.")
        }
    }
    
    func testRequestStoreRemove() {
        
        let expectation = self.expectation(withDescription: "Test Request Store")
        
        let store = RequestStore()
        
        let urlString = "https://httpbin.org/get"
        let task = URLSession.shared().dataTask(with: URL(string: urlString)!) { (_, _, _) in
            
            store.removeRequestFor(urlString: urlString)
            
            if store.containsRequestWithURL(urlString) {
                XCTAssert(false, "Task not removed after completion.")
            } else {
                XCTAssert(true, "Task removed after completion.")
            }
            expectation.fulfill()
        }
        store.addRequest(task, urlString: urlString)
        task.resume()
        
        waitForExpectations(withTimeout: 120, handler: { (completionHandler) -> Void in })
    }
    
}
