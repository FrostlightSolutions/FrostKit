//
//  BundleExtensionsTests.swift
//  FrostKit
//
//  Created by James Barrow on 26/02/2016.
//  Copyright © 2016 James Barrow - Frostlight Solutions. All rights reserved.
//

import XCTest
import FrostKit

class BundleExtensionsTests: XCTestCase {
    
    let bundle = Bundle(identifier: "com.Frostlight.FrostKit")!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testBundleAppVersion() {
        
        let version = bundle.objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        measureBlock { () -> Void in
            XCTAssert(Bundle.appVersion(self.bundle) == version)
        }
    }
    
    func testBundleAppBuildNumber() {
        
        let buildNumber = bundle.objectForInfoDictionaryKey("CFBundleVersion") as! String
        measureBlock { () -> Void in
            XCTAssert(Bundle.appBuildNumber(self.bundle) == buildNumber)
        }
    }
    
    func testBundleAppName() {
        
        measureBlock { () -> Void in
            XCTAssert(Bundle.appName(self.bundle) == "FrostKit")
        }
    }
    
}
