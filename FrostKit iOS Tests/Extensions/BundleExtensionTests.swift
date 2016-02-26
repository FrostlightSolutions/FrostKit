//
//  BundleExtensionTests.swift
//  FrostKit
//
//  Created by James Barrow on 26/02/2016.
//  Copyright © 2016 James Barrow - Frostlight Solutions. All rights reserved.
//

import XCTest
import FrostKit

class BundleExtensionTests: XCTestCase {
    
    let bundle = NSBundle(identifier: "com.Frostlight.FrostKit")!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testBundleAppVersion() {
        
        measureBlock { () -> Void in
            XCTAssert(NSBundle.appVersion(self.bundle) == "1")
        }
    }
    
    func testBundleAppName() {
        
        measureBlock { () -> Void in
            XCTAssert(NSBundle.appName(self.bundle) == "FrostKit")
        }
    }
    
}
