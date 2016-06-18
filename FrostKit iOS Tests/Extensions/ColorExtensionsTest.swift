//
//  ColorExtensionsTest.swift
//  FrostKit
//
//  Created by Niels Lemmens on 01/10/2014.
//  Copyright © 2014-Current James Barrow - Frostlight Solutions. All rights reserved.
//

import XCTest
@testable import FrostKit

class ColorExtensionsTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSimpleHexColors() {
        
        measure { () -> Void in
            
            XCTAssert(Color.colorWithHex("#ffffff") == Color(red: 1, green: 1, blue: 1, alpha: 1), "Pass")
            XCTAssert(Color.colorWithHex("#123456") == Color(red: 18.0/255, green: 52.0/255, blue: 86.0/255, alpha: 1), "Pass")
        }
    }
    
    func testHexHashtag() {
        
        measureBlock { () -> Void in
            
            // With or without #
            XCTAssert(Color.colorWithHex("#479123") == Color.colorWithHex("479123"), "Pass")
        }
    }
    
    func testShortHex() {
        
        measure { () -> Void in
            
            // 3 chars work as well as 6
            XCTAssert(Color.colorWithHex("#123") == Color.colorWithHex("#112233"), "Pass")
            // Regardless of #
            XCTAssert(Color.colorWithHex("123") == Color.colorWithHex("#112233"), "Pass")
        }
    }
    
    func testUnsuposedHexFormat() {
        
        measure { () -> Void in
            
            // 4 char hex should not parse and return default clearColor()
            XCTAssert(Color.colorWithHex("#1234") == Color.clearColor(), "Pass")
            // Regardless of #
            XCTAssert(Color.colorWithHex("1234") == Color.clearColor(), "Pass")
        }
    }
    
}
