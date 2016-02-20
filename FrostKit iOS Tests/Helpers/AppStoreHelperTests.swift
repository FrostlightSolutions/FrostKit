//
//  AppStoreHelperTests.swift
//  FrostKit
//
//  Created by James Barrow on 07/11/2015.
//  Copyright © 2015 James Barrow - Frostlight Solutions. All rights reserved.
//

import XCTest
import FrostKit

class AppStoreHelperTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAppStoreUpdate() {
        
        let expectation = expectationWithDescription("Test App Store Update")
        
        FrostKit.setupAppStoreID("571254467")
        
        AppStoreHelper.shared.updateAppStoreData { (error) -> Void in
            
            if let anError = error {
                XCTAssert(false, "App Store Detail Update Error: \(anError.localizedDescription)")
            } else {
                XCTAssert(true, "App Store Details Updated")
            }
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(expectationTimeout, handler: { (completionHandler) -> Void in })
    }
    
}
