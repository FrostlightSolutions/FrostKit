//
//  FontExtensionsTests.swift
//  FrostKit
//
//  Created by James Barrow on 26/02/2016.
//  Copyright © 2016-Current James Barrow - Frostlight Solutions. All rights reserved.
//

import XCTest
@testable import FrostKit

class FontExtensionsTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCustomFonts() {
        
        measure { () -> Void in
            
            let fontAwesome = Font.fontAwesome(ofSize: 12)
            let fontAwesomeName = fontAwesome.fontName
            XCTAssert(fontAwesomeName == "FontAwesome", "Font name is: \(fontAwesomeName)")
            let ionicons = Font.ionicons(ofSize: 12)
            let ioniconsName = ionicons.fontName
            XCTAssert(ioniconsName == "Ionicons", "Font name is: \(ioniconsName)")
        }
    }
    
}
