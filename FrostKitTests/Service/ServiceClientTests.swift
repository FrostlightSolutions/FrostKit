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

class ServiceClientTests: XCTestCase {
    
    let username = "frostkit"
    let password = "frostkit"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        UserStore.current
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        UserStore.saveUser()
        
        super.tearDown()
    }
    
    func testLogin() {
        
        let expectation = expectationWithDescription("Test Login")
        
        login { (error) -> () in
            if let anError = error {
                XCTAssert(false, "Login Error: \(anError.localizedDescription)")
            } else {
                XCTAssert(true, "Logged In")
            }
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(expectationTimeout, handler: { (completionHandler) -> Void in })
    }
    
    func testLoginAndThenRefresh() {
        
        let expectation = expectationWithDescription("Test Login then Refresh")
        
        login { (loginError) -> () in
            if let lError = loginError {
                XCTAssert(false, "Login Error: \(lError.localizedDescription)")
                expectation.fulfill()
            } else {
                self.refresh({ (refreshError) -> () in
                    if let rError = refreshError {
                        XCTAssert(false, "Refresh Error: \(rError.localizedDescription)")
                    } else {
                        XCTAssert(true, "Refreshed")
                    }
                    expectation.fulfill()
                })
            }
        }
        
        self.waitForExpectationsWithTimeout(expectationTimeout, handler: { (completionHandler) -> Void in })
    }
    
    func testNotificationsGetRequest() {
        
        let expectation = expectationWithDescription("Test Notifications Get Request")
        
        login { (loginError) -> () in
            if let lError = loginError {
                XCTAssert(false, "Login Error: \(lError.localizedDescription)")
                expectation.fulfill()
            } else {
                self.refresh({ (refreshError) -> () in
                    if let rError = refreshError {
                        XCTAssert(false, "Refresh Error: \(rError.localizedDescription)")
                        expectation.fulfill()
                    } else {
                        self.getNotificationsRequest({ (notifError) -> () in
                            if let nError = notifError {
                                XCTAssert(false, "Failed to get Notifications \(nError.localizedDescription)")
                            } else {
                                XCTAssert(true, "Got Notifications Response")
                            }
                            expectation.fulfill()
                        })
                    }
                })
            }
        }
        
        self.waitForExpectationsWithTimeout(expectationTimeout, handler: { (completionHandler) -> Void in })
    }
    
    func login(complete: (NSError?) -> ()) {
        ServiceClient.loginUser(username: username, password: password) { (error) -> () in
            complete(error)
        }
    }
    
    func refresh(complete: (NSError?) -> ()) {
        ServiceClient.refreshOAuthToken() { (error) -> () in
            complete(error)
        }
    }
    
    func getNotificationsRequest(complete: (NSError?) -> ()) {
        ServiceClient.request(Router.Notifications(1), completed: { (json, error) -> () in
            complete(error)
        })
    }
    
}
