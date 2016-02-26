//
//  ColorExtensionsTest.swift
//  FrostKit
//
//  Created by Niels Lemmens on 01/10/2014.
//  Copyright (c) 2014-2015 James Barrow - Frostlight Solutions. All rights reserved.
//

import XCTest

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
        
        measureBlock { () -> Void in
            
            XCTAssert(UIColor.colorWithHex("#ffffff") == UIColor(red: 1, green: 1, blue: 1, alpha: 1), "Pass")
            XCTAssert(UIColor.colorWithHex("#123456") == UIColor(red: 18.0/255, green: 52.0/255, blue: 86.0/255, alpha: 1), "Pass")
        }
    }
    
    func testHexHashtag() {
        
        measureBlock { () -> Void in
            
            // With or without #
            XCTAssert(UIColor.colorWithHex("#479123") == UIColor.colorWithHex("479123"), "Pass")
        }
    }
    
    func testShortHex() {
        
        measureBlock { () -> Void in
            
            // 3 chars work as well as 6
            XCTAssert(UIColor.colorWithHex("#123") == UIColor.colorWithHex("#112233"), "Pass")
            // Regardless of #
            XCTAssert(UIColor.colorWithHex("123") == UIColor.colorWithHex("#112233"), "Pass")
        }
    }
    
    func testUnsuposedHexFormat() {
        
        measureBlock { () -> Void in
            
            // 4 char hex should not parse and return default clearColor()
            XCTAssert(UIColor.colorWithHex("#1234") == UIColor.clearColor(), "Pass")
            // Regardless of #
            XCTAssert(UIColor.colorWithHex("1234") == UIColor.clearColor(), "Pass")
        }
    }
    
}
