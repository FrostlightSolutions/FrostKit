//
//  NSDateExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright (c) 2014 Frostlight Solutions. All rights reserved.
//

import UIKit
import XCTest
import FrostKit

class NSDateExtensions: XCTestCase {
   
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIsToday() {
        
        let date = NSDate.date()
        XCTAssert(date.isToday, "Pass")
    }
    
    func testIsTomorrow() {
        let date = NSDate(timeIntervalSinceNow: 24*60*60)
        XCTAssert(date.isTomorrow, "Pass")
    }
    
    func testIsYesterday() {
        let date = NSDate(timeIntervalSinceNow: -24*60*60)
        XCTAssert(date.isYesterday, "Pass")
    }
    
}
