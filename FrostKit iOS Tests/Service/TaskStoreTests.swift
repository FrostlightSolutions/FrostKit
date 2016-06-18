//
//  TaskStoreTests.swift
//  FrostKit
//
//  Created by James Barrow on 18/06/2016.
//  Copyright © 2016-Current James Barrow - Frostlight Solutions. All rights reserved.
//

import XCTest
@testable import FrostKit

class TaskStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTaskStoreAdd() {
        
        let store = TaskStore()
        
        let urlString = "https://httpbin.org/get"
        let task = URLSession.shared().dataTask(with: URL(string: urlString)!)
        store.add(task, urlString: urlString)
        
        if store.contains(taskWithURL: urlString) {
            XCTAssert(true, "Task added to the store.")
        } else {
            XCTAssert(false, "Task not added to the store.")
        }
    }
    
    func testRequestStoreRemove() {
        
        let expectation = self.expectation(withDescription: "Test Request Store")
        
        let store = TaskStore()
        
        let urlString = "https://httpbin.org/get"
        let task = URLSession.shared().dataTask(with: URL(string: urlString)!) { (_, _, _) in
            
            store.remove(taskWithURL: urlString)
            
            if store.contains(taskWithURL: urlString) {
                XCTAssert(false, "Task not removed after completion.")
            } else {
                XCTAssert(true, "Task removed after completion.")
            }
            expectation.fulfill()
        }
        store.add(task, urlString: urlString)
        task.resume()
        
        waitForExpectations(withTimeout: 120, handler: { (completionHandler) -> Void in })
    }
    
}
