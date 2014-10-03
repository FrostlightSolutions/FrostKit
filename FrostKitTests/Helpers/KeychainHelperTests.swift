//
//  KeychainHelperTests.swift
//  FrostKit
//
//  Created by James Barrow on 04/10/2014.
//  Copyright (c) 2014 Frostlight Solutions. All rights reserved.
//

import XCTest
import FrostKit

class KeychainHelperTests: XCTestCase {
    
    let username = "myName"
    let password = "qwerty1234567890!_<>,.!@#$%^&*()_+-=/?"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSetKeychain() {
        XCTAssert(KeychainHelper.setDetails(password: password, username: username), "Pass")
    }
    
    func testSetUpdateKeychain() {
        XCTAssert(KeychainHelper.setDetails(password: password, username: username), "Pass")
    }
    
    func testDeleteKeychain() {
        XCTAssert(KeychainHelper.deleteKeychain(), "Pass")
    }
    
}
