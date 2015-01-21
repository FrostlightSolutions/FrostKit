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
    
}
