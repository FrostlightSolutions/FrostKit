//
//  DateExtensionsTests.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright © 2014 - 2017 James Barrow - Frostlight Solutions. All rights reserved.
//

import XCTest
@testable import FrostKit

class DateExtensionsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFusDate() {
        
        measure { () in
            
            let dateString = "2016-02-26"
            let date = Date.fusDate(from: dateString)
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601
            components.timeZone = TimeZone.utc
            components.year = 2016
            components.month = 2
            components.day = 26
            
            XCTAssert(components.date == date)
        }
    }
    
    func testFusDateAndTime() {
        
        measure { () in
            
            let dateString = "2016-02-26T15:24:48.000000Z"
            let date = Date.fusDate(from: dateString)
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601
            components.timeZone = TimeZone.utc
            components.year = 2016
            components.month = 2
            components.day = 26
            components.hour = 15
            components.minute = 24
            components.second = 48
            
            XCTAssert(components.date == date)
        }
    }
    
    func testIsYesterday() {
        
        measure { () in
            
            let date = Date(timeIntervalSinceNow: -24 * 60 * 60)
            XCTAssert(date.isYesterday, "Pass")
        }
    }
    
    func testIsToday() {
        
        measure { () in
            
            let date = Date()
            XCTAssert(date.isToday, "Pass")
        }
    }
    
    func testIsTomorrow() {
        
        measure { () in
            
            let date = Date(timeIntervalSinceNow: 24 * 60 * 60)
            XCTAssert(date.isTomorrow, "Pass")
        }
    }
    
    func testIsWeekday() {
        
        measure { () in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601
            components.year = 2016
            components.month = 2
            
            components.day = 22 // Monday
            XCTAssert(components.date?.isWeekday == true)
            components.day = 23 // Tuesday
            XCTAssert(components.date?.isWeekday == true)
            components.day = 24 // Wednesday
            XCTAssert(components.date?.isWeekday == true)
            components.day = 25 // Thursday
            XCTAssert(components.date?.isWeekday == true)
            components.day = 26 // Friday
            XCTAssert(components.date?.isWeekday == true)
            components.day = 27 // Saturday
            XCTAssert(components.date?.isWeekday == false)
            components.day = 28 // Sunday
            XCTAssert(components.date?.isWeekday == false)
        }
    }
    
    func testIsBeginingOfWeek() {
        
        measure { () in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601
            components.year = 2016
            components.month = 2
            
            components.day = 22 // Monday
            XCTAssert(components.date?.isBeginingOfWeek == true)
            components.day = 23 // Tuesday
            XCTAssert(components.date?.isBeginingOfWeek == false)
            components.day = 24 // Wednesday
            XCTAssert(components.date?.isBeginingOfWeek == false)
            components.day = 25 // Thursday
            XCTAssert(components.date?.isBeginingOfWeek == false)
            components.day = 26 // Friday
            XCTAssert(components.date?.isBeginingOfWeek == false)
            components.day = 27 // Saturday
            XCTAssert(components.date?.isBeginingOfWeek == false)
            components.day = 28 // Sunday
            XCTAssert(components.date?.isBeginingOfWeek == false)
        }
    }
    
    func testIsEndOfWeek() {
        
        measure { () in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601
            components.year = 2016
            components.month = 2
            
            components.day = 22 // Monday
            XCTAssert(components.date?.isEndOfWeek == false)
            components.day = 23 // Tuesday
            XCTAssert(components.date?.isEndOfWeek == false)
            components.day = 24 // Wednesday
            XCTAssert(components.date?.isEndOfWeek == false)
            components.day = 25 // Thursday
            XCTAssert(components.date?.isEndOfWeek == false)
            components.day = 26 // Friday
            XCTAssert(components.date?.isEndOfWeek == false)
            components.day = 27 // Saturday
            XCTAssert(components.date?.isEndOfWeek == false)
            components.day = 28 // Sunday
            XCTAssert(components.date?.isEndOfWeek == true)
        }
    }
    
    func testIsBeginingOfMonth() {
        
        measure { () in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601
            components.year = 2016
            components.month = 2
            
            components.day = 29
            XCTAssert(components.date?.isBeginingOfMonth == false)
            components.month = 3
            components.day = 1
            XCTAssert(components.date?.isBeginingOfMonth == true)
            components.day = 2
            XCTAssert(components.date?.isBeginingOfMonth == false)
        }
    }
    
    func testIsEndOfMonth() {
        
        measure { () in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601
            components.year = 2016
            components.month = 2
            
            components.day = 28
            XCTAssert(components.date?.isEndOfMonth == false)
            components.day = 29
            XCTAssert(components.date?.isEndOfMonth == true)
            components.month = 3
            components.day = 1
            XCTAssert(components.date?.isEndOfMonth == false)
        }
    }
    
    func testDay() {
        
        measure { () in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601
            components.day = 26
            
            XCTAssert(components.date?.day == 26)
        }
    }
    
    func testHour() {
        
        measure { () in
            
            let hour = 19
            var components = DateComponents()
            components.calendar = Calendar.iso8601
            components.hour = hour
            
            XCTAssert(components.date?.hour == hour)
        }
    }
    
    func testMinute() {
        
        measure { () in
            
            let minute = 47
            var components = DateComponents()
            components.calendar = Calendar.iso8601
            components.minute = minute
            
            XCTAssert(components.date?.minute == minute)
        }
    }
    
    func testTimeInHours() {
        
        measure { () in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601
            components.hour = 15
            components.minute = 45
            
            XCTAssert(components.date?.timeInHours == 15.75)
        }
    }
    
    func testSecondsComponents() {
        
        measure { () in
            
            XCTAssert(Date.minuteInSeconds == 60)
            XCTAssert(Date.hourInSeconds == 3600)
            XCTAssert(Date.dayInSeconds == 86400)
            XCTAssert(Date.weekInSeconds == 604_800)
        }
    }
    
    func testDaysBetweenDates() {
        
        measure { () in
            
            let daysBetween = 3
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601
            components.year = 2016
            components.month = 2
            components.day = 26
            
            let fromDate = components.date
            if let day = components.day {
                components.day = day + daysBetween
            } else {
                components.day = daysBetween
            }
            let toDate = components.date
            
            let calculatedDaysBetween = Date.daysBetween(fromDate!, to: toDate!)!
            XCTAssert(calculatedDaysBetween == daysBetween, "Expected: \(daysBetween) but got: \(calculatedDaysBetween)")
        }
    }
    
    func testDaysRemainingInWeek() {
        
        measure { () in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601
            components.year = 2016
            components.month = 2
            components.day = 26
            
            XCTAssert(components.date?.daysRemainingInWeek == 3)
            components.day = 28
            XCTAssert(components.date?.daysRemainingInWeek == 1)
        }
    }
    
    func testDaysInMonth() {
        
        measure { () in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601
            components.year = 2016
            components.month = 2
            components.day = 26
            
            let daysInMonth = 29
            let calculatedDaysInMonth = components.date!.daysInMonth
            XCTAssert(calculatedDaysInMonth == daysInMonth, "Expected: \(daysInMonth) but got: \(calculatedDaysInMonth)")
        }
    }
    
    func testDaysRemainingInMonth() {
        
        measure { () in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601
            components.year = 2016
            components.month = 2
            components.day = 26
            
            let daysRemainingInMonth = 3
            let calculatedDaysRemainingInMonth = components.date!.daysRemainingInMonth!
            XCTAssert(calculatedDaysRemainingInMonth == daysRemainingInMonth, "Expected: \(daysRemainingInMonth) but got: \(calculatedDaysRemainingInMonth)")
        }
    }
    
    func testCompareDatesWithinMonth() {
        
        measure { () in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601
            components.year = 2016
            components.month = 2
            components.day = 26
            
            let date = components.date!
            components.day = 28
            XCTAssert(date.isBefore(components.date!) == true)
            XCTAssert(date.isAfter(components.date!) == false)
            
            XCTAssert(date.compare(components.date!, option: .before, shouldStripTime: false) == true)
            XCTAssert(date.compare(components.date!, option: .after, shouldStripTime: false) == false)
            XCTAssert(date.compare(components.date!, option: .equalTo, shouldStripTime: false) == false)
            XCTAssert(date.compare(components.date!, option: .beforeOrEqualTo, shouldStripTime: false) == true)
            XCTAssert(date.compare(components.date!, option: .afterOrEqualTo, shouldStripTime: false) == false)
            
            components.day = 26
            XCTAssert(date.compare(components.date!, option: .equalTo, shouldStripTime: false) == true)
            XCTAssert(date.compare(components.date!, option: .beforeOrEqualTo, shouldStripTime: false) == true)
            XCTAssert(date.compare(components.date!, option: .afterOrEqualTo, shouldStripTime: false) == true)
            
            components.day = 11
            XCTAssert(date.isBefore(components.date!) == false)
            XCTAssert(date.isAfter(components.date!) == true)
            
            XCTAssert(date.compare(components.date!, option: .before, shouldStripTime: false) == false)
            XCTAssert(date.compare(components.date!, option: .after, shouldStripTime: false) == true)
            XCTAssert(date.compare(components.date!, option: .equalTo, shouldStripTime: false) == false)
            XCTAssert(date.compare(components.date!, option: .beforeOrEqualTo, shouldStripTime: false) == false)
            XCTAssert(date.compare(components.date!, option: .afterOrEqualTo, shouldStripTime: false) == true)
        }
    }
    
    func testCompareDatesBetweenMonth() {
        
        measure { () in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601
            components.year = 2016
            components.month = 2
            components.day = 26
            
            let date = components.date!
            components.month = 3
            components.day = 28
            XCTAssert(date.isBefore(components.date!) == true)
            XCTAssert(date.isAfter(components.date!) == false)
            
            XCTAssert(date.compare(components.date!, option: .before, shouldStripTime: false) == true)
            XCTAssert(date.compare(components.date!, option: .after, shouldStripTime: false) == false)
            XCTAssert(date.compare(components.date!, option: .equalTo, shouldStripTime: false) == false)
            XCTAssert(date.compare(components.date!, option: .beforeOrEqualTo, shouldStripTime: false) == true)
            XCTAssert(date.compare(components.date!, option: .afterOrEqualTo, shouldStripTime: false) == false)
            
            components.day = 26
            XCTAssert(date.compare(components.date!, option: .equalTo, shouldStripTime: false) == false)
            XCTAssert(date.compare(components.date!, option: .beforeOrEqualTo, shouldStripTime: false) == true)
            XCTAssert(date.compare(components.date!, option: .afterOrEqualTo, shouldStripTime: false) == false)
            
            components.month = 1
            XCTAssert(date.compare(components.date!, option: .equalTo, shouldStripTime: false) == false)
            XCTAssert(date.compare(components.date!, option: .beforeOrEqualTo, shouldStripTime: false) == false)
            XCTAssert(date.compare(components.date!, option: .afterOrEqualTo, shouldStripTime: false) == true)
            
            components.day = 11
            XCTAssert(date.isBefore(components.date!) == false)
            XCTAssert(date.isAfter(components.date!) == true)
            
            XCTAssert(date.compare(components.date!, option: .before, shouldStripTime: false) == false)
            XCTAssert(date.compare(components.date!, option: .after, shouldStripTime: false) == true)
            XCTAssert(date.compare(components.date!, option: .equalTo, shouldStripTime: false) == false)
            XCTAssert(date.compare(components.date!, option: .beforeOrEqualTo, shouldStripTime: false) == false)
            XCTAssert(date.compare(components.date!, option: .afterOrEqualTo, shouldStripTime: false) == true)
        }
    }
    
    func testCompareDatesBetweenYears() {
        
        measure { () in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601
            components.year = 2016
            components.month = 2
            components.day = 26
            
            let date = components.date!
            components.year = 2017
            components.day = 28
            XCTAssert(date.isBefore(components.date!) == true)
            XCTAssert(date.isAfter(components.date!) == false)
            
            XCTAssert(date.compare(components.date!, option: .before, shouldStripTime: false) == true)
            XCTAssert(date.compare(components.date!, option: .after, shouldStripTime: false) == false)
            XCTAssert(date.compare(components.date!, option: .equalTo, shouldStripTime: false) == false)
            XCTAssert(date.compare(components.date!, option: .beforeOrEqualTo, shouldStripTime: false) == true)
            XCTAssert(date.compare(components.date!, option: .afterOrEqualTo, shouldStripTime: false) == false)
            
            components.day = 26
            XCTAssert(date.compare(components.date!, option: .equalTo, shouldStripTime: false) == false)
            XCTAssert(date.compare(components.date!, option: .beforeOrEqualTo, shouldStripTime: false) == true)
            XCTAssert(date.compare(components.date!, option: .afterOrEqualTo, shouldStripTime: false) == false)
            
            components.year = 2015
            XCTAssert(date.compare(components.date!, option: .equalTo, shouldStripTime: false) == false)
            XCTAssert(date.compare(components.date!, option: .beforeOrEqualTo, shouldStripTime: false) == false)
            XCTAssert(date.compare(components.date!, option: .afterOrEqualTo, shouldStripTime: false) == true)
            
            components.day = 11
            XCTAssert(date.isBefore(components.date!) == false)
            XCTAssert(date.isAfter(components.date!) == true)
            
            XCTAssert(date.compare(components.date!, option: .before, shouldStripTime: false) == false)
            XCTAssert(date.compare(components.date!, option: .after, shouldStripTime: false) == true)
            XCTAssert(date.compare(components.date!, option: .equalTo, shouldStripTime: false) == false)
            XCTAssert(date.compare(components.date!, option: .beforeOrEqualTo, shouldStripTime: false) == false)
            XCTAssert(date.compare(components.date!, option: .afterOrEqualTo, shouldStripTime: false) == true)
        }
    }
    
    func testStripTime() {
        
        measure { () in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601
            components.year = 2016
            components.month = 2
            components.day = 26
            components.hour = 19
            components.minute = 12
            components.second = 43
            
            let date = components.date!
            let strippedDate = date.stripTime
            components.hour = 0
            components.minute = 0
            components.second = 0
            XCTAssert(strippedDate == components.date, "Should be \"\(components.date!)\" but was \"\(strippedDate!)\"")
        }
    }
    
    func testDateByAddingDays() {
        
        measure { () in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601
            components.year = 2016
            components.month = 2
            components.day = 26
            let date = components.date!
            
            XCTAssert(date.dateByAdding(days: 0) == date)
            components.day! += 3
            XCTAssert(date.dateByAdding(days: 3) == components.date)
            components.day! -= 5
            XCTAssert(date.dateByAdding(days: -2) == components.date)
            components.day! += 92
            XCTAssert(date.dateByAdding(days: 90) == components.date)
            components.day! -= 180
            XCTAssert(date.dateByAdding(days: -90) == components.date)
            components.day! -= 390
            XCTAssert(date.dateByAdding(days: -480) == components.date)
            components.day! += 960
            XCTAssert(date.dateByAdding(days: 480) == components.date)
        }
    }
    
    func testDateAt() {
        
        measure { () in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601
            components.year = 2016
            components.month = 2
            components.day = 26
            components.hour = 19
            components.minute = 12
            components.second = 43
            let date = components.date!
            
            components.hour = 0
            components.minute = 0
            components.second = 0
            XCTAssert(date.dateAtStartOfDay == components.date, "Should be \"\(components.date!)\" but was \"\(date.dateAtStartOfDay)\"")
            
            components.hour = 23
            components.minute = 59
            components.second = 59
            XCTAssert(date.dateAtEndOfDay == components.date, "Should be \"\(components.date!)\" but was \"\(date.dateAtEndOfDay!)\"")
        }
    }
    
}
