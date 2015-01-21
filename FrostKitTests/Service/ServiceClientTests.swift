//
//  FrostKitTests.swift
//  FrostKitTests
//
//  Created by James Barrow on 29/09/2014.
//  Copyright (c) 2014 Frostlight Solutions. All rights reserved.
//

import UIKit
import XCTest
import FrostKit

let expectationTimeout: NSTimeInterval = 60

class ServiceClientTests: XCTestCase {
    
    let username = "odin"
    let password = "odin"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        UserStore.shared
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        UserStore.saveUser()
        
        super.tearDown()
    }
    
    func testLogin() {
        
        let expectation = expectationWithDescription("Test Login")
        
        login { () -> () in
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(expectationTimeout, handler: { (completionHandler) -> Void in })
    }
    
    func testLoginAndThenRefresh() {
        
        let expectation = expectationWithDescription("Test Login")
        
        login { () -> () in
            self.refresh({ () -> () in
                expectation.fulfill()
            })
        }
        
        self.waitForExpectationsWithTimeout(expectationTimeout, handler: { (completionHandler) -> Void in })
    }
    
    func login(complete: () -> ()) {
        ServiceClient.loginUser(username: username, password: password) { (error) -> () in
            if let anError = error {
                XCTAssert(false, "Login Error: \(anError.localizedDescription)")
            } else {
                XCTAssert(true, "Logged In")
            }
            complete()
        }
    }
    
    func refresh(complete: () -> ()) {
        ServiceClient.refreshOAuthToken() { (error) -> () in
            if let anError = error {
                XCTAssert(false, "Login Error: \(anError.localizedDescription)")
            } else {
                XCTAssert(true, "Logged In")
            }
            complete()
        }
    }
    
     var pagedStore: PagedStore {
        let pagedStore = PagedStore(totalCount: 8, objectsPerPage: 3)
        pagedStore.setObjects(["1", "2", "3"], page: 1)
        pagedStore.setObjects(["4", "5", "6"], page: 2)
        pagedStore.setObjects(["7", "8"], page: 3)
        return pagedStore
    }
    
    func testPagedStoreSecondPageSubscript() {
        
        let four = pagedStore[3] as String
        if four == "4" {
            XCTAssert(true, "Success! 1st item of the 2nd page is \(four)")
        } else {
            XCTAssert(false, "Failed! 1st item of the 2nd page is \(four) instead of 4")
        }
    }
    
    func testPagedStoreCount() {
        
        let count = pagedStore.count
        if count == 8 {
            XCTAssert(true, "Success! Count is \(count)")
        } else {
            XCTAssert(false, "Failed! Count is \(count) instead of 8")
        }
    }
    
    func testPagedStoreFirstObject() {
        
        let object = pagedStore.firstObject as String
        if object == "1" {
            XCTAssert(true, "Success! First object is \(object)")
        } else {
            XCTAssert(false, "Failed! First object is \(object) instead of 1")
        }
    }
    
    func testPagedStoreLastObject() {
        
        let object = pagedStore.lastObject as String
        if object == "8" {
            XCTAssert(true, "Success! Lasr object is \(object)")
        } else {
            XCTAssert(false, "Failed! Last object is \(object) instead of 1")
        }
    }
    
    func testPagedStoreUpdateBiggerTotalCount() {
        
        let pagedStore = self.pagedStore
        pagedStore.setObjects(["7", "8", "9"], page: 3, totalCount: 9)
        let count = pagedStore.count
        if count == 9 {
            XCTAssert(true, "Success! Count is now \(count)")
        } else {
            XCTAssert(false, "Failed! Count is \(count) instead of 9")
        }
    }
    
    func testPagedStoreUpdateSmallerTotalCount() {
        
        let pagedStore = self.pagedStore
        pagedStore.setObjects(["4"], page: 2, totalCount: 4)
        let count = pagedStore.count
        if count == 4 {
            XCTAssert(true, "Success! Count is now \(count)")
        } else {
            XCTAssert(false, "Failed! Count is \(count) instead of 4")
        }
    }
    
}
