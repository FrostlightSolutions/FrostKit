//
//  DataExtensionTests.swift
//  FrostKit
//
//  Created by James Barrow on 26/02/2016.
//  Copyright © 2016 - 2017 James Barrow - Frostlight Solutions. All rights reserved.
//

import XCTest
@testable import FrostKit

class DataExtensionTests: XCTestCase {
    
    let data = "FrostKit".data(using: String.Encoding.utf8)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testHexString() {
        
        measure { () in
            
            let convertedHexString = self.data?.hexString
            XCTAssert(convertedHexString == "46726f73744b6974")
        }
    }
    
}
