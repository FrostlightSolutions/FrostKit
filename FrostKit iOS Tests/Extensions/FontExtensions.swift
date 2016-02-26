//
//  FontExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 26/02/2016.
//  Copyright © 2016 James Barrow - Frostlight Solutions. All rights reserved.
//

import XCTest

class FontExtensions: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCustomFonts() {
        
        measureBlock { () -> Void in
            
            let fontAwesome = UIFont.fontAwesome(size: 12)
            XCTAssert(fontAwesome.fontName == "FontAwesome")
            let ionicons = UIFont.ionicons(size: 12)
            XCTAssert(ionicons.fontName == "Ionicons")
        }
    }
    
}
