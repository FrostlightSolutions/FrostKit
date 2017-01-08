//
//  BundleExtensionsTests.swift
//  FrostKit
//
//  Created by James Barrow on 26/02/2016.
//  Copyright © 2016 - 2017 James Barrow - Frostlight Solutions. All rights reserved.
//

import XCTest
@testable import FrostKit

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
        
        let version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        measure { () -> Void in
            XCTAssert(Bundle.appVersion(self.bundle) == version)
        }
    }
    
    func testBundleAppBuildNumber() {
        
        let buildNumber = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        measure { () -> Void in
            XCTAssert(Bundle.appBuildNumber(self.bundle) == buildNumber)
        }
    }
    
    func testBundleAppName() {
        
        measure { () -> Void in
            XCTAssert(Bundle.appName(self.bundle) == "FrostKit")
        }
    }
    
}
