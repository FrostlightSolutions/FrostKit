//
//  NSDateExtensionsTests.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright (c) 2014-2015 James Barrow - Frostlight Solutions. All rights reserved.
//

import XCTest
import FrostKit

class DateExtensionsTests: XCTestCase {
   
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIsYesterday() {
        
        measureBlock { () -> Void in
            
            let date = NSDate(timeIntervalSinceNow: -24*60*60)
            XCTAssert(date.isYesterday, "Pass")
        }
    }
    
    func testIsToday() {
        
        measureBlock { () -> Void in
            
            let date = NSDate()
            XCTAssert(date.isToday, "Pass")
        }
    }
    
    func testIsTomorrow() {
        
        measureBlock { () -> Void in
            
            let date = NSDate(timeIntervalSinceNow: 24*60*60)
            XCTAssert(date.isTomorrow, "Pass")
        }
    }
    
}
