//
//  AppStoreHelperTests.swift
//  FrostKit
//
//  Created by James Barrow on 07/11/2015.
//  Copyright © 2015 - 2017 James Barrow - Frostlight Solutions. All rights reserved.
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
        
        let expectation = self.expectation(description: "Test App Store Update")
        
        FrostKit.setup(appStoreID: "538357667")
        
        AppStoreHelper.shared.updateAppStoreData { result in
            
            switch result {
            case .failure(let error):
                XCTAssert(false, "App Store Detail Update Error: \(error.localizedDescription)")
            case .success:
                XCTAssert(true, "App Store Details Updated")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 120, handler: { (_) in })
    }
}
