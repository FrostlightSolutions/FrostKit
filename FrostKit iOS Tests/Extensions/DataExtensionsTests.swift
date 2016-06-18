//
//  DataExtensionTests.swift
//  FrostKit
//
//  Created by James Barrow on 26/02/2016.
//  Copyright © 2016-Current James Barrow - Frostlight Solutions. All rights reserved.
//

import XCTest
@testable import FrostKit

class DataExtensionTests: XCTestCase {
    
    let data = "FrostKit".dataUsingEncoding(NSUTF8StringEncoding)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testHexString() {
        
        measureBlock { () -> Void in
            
            let convertedHexString = self.data?.hexString
            XCTAssert(convertedHexString == "46726f73744b6974")
        }
    }
    
    func testSizeFormattedString() {
        
        measureBlock { () -> Void in
            
            XCTAssert(NSData.sizeFormattedString(0) == "0 B")
            XCTAssert(NSData.sizeFormattedString(1) == "1 B")
            XCTAssert(NSData.sizeFormattedString(1_024) == "1 KB")
            XCTAssert(NSData.sizeFormattedString(1_048_576) == "1 MB")
            XCTAssert(NSData.sizeFormattedString(1_073_741_824) == "1 GB")
            XCTAssert(NSData.sizeFormattedString(1_099_511_627_776) == "1 TB")
            XCTAssert(NSData.sizeFormattedString(1_125_899_906_842_624) == "1 PB")
            XCTAssert(NSData.sizeFormattedString(1_152_921_504_606_846_976) == "1 EB")
            XCTAssert(self.data?.lengthFormattedString == "8 B")
        }
    }
    
}
