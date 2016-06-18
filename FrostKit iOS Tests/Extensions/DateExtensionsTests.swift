//
//  DateExtensionsTests.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright © 2014-Current James Barrow - Frostlight Solutions. All rights reserved.
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
        
        measure { () -> Void in
            
            let dateString = "2016-02-26"
            let date = Date.fusDate(from: dateString)
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601Calendar()
            components.timeZone = TimeZone.utc()
            components.year = 2016
            components.month = 2
            components.day = 26
            
            XCTAssert(components.date == date)
        }
    }
    
    func testFusDateAndTime() {
        
        measure { () -> Void in
            
            let dateString = "2016-02-26T15:24:48.000000Z"
            let date = Date.fusDate(from: dateString)
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601Calendar()
            components.timeZone = TimeZone.utc()
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
        
        measure { () -> Void in
            
            let date = Date(timeIntervalSinceNow: -24*60*60)
            XCTAssert(date.isYesterday, "Pass")
        }
    }
    
    func testIsToday() {
        
        measure { () -> Void in
            
            let date = Date()
            XCTAssert(date.isToday, "Pass")
        }
    }
    
    func testIsTomorrow() {
        
        measure { () -> Void in
            
            let date = Date(timeIntervalSinceNow: 24*60*60)
            XCTAssert(date.isTomorrow, "Pass")
        }
    }
    
    func testIsWeekday() {
        
        measure { () -> Void in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601Calendar()
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
    
    func testIsBeginingOfWeek () {
        
        measure { () -> Void in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601Calendar()
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
    
    func testIsEndOfWeek () {
        
        measure { () -> Void in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601Calendar()
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
    
    func testIsBeginingOfMonth () {
        
        measure { () -> Void in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601Calendar()
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
    
    func testIsEndOfMonth () {
        
        measure { () -> Void in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601Calendar()
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
        
        measure { () -> Void in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601Calendar()
            components.day = 26
            
            XCTAssert(components.date?.day == 26)
        }
    }
    
    func testHour() {
        
        measure { () -> Void in
            
            let hour = 19
            var components = DateComponents()
            components.calendar = Calendar.iso8601Calendar()
            components.hour = hour
            
            XCTAssert(components.date?.hour == hour)
        }
    }
    
    func testMinute() {
        
        measure { () -> Void in
            
            let minute = 47
            var components = DateComponents()
            components.calendar = Calendar.iso8601Calendar()
            components.minute = minute
            
            XCTAssert(components.date?.minute == minute)
        }
    }
    
    func testTimeInHours() {
        
        measure { () -> Void in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601Calendar()
            components.hour = 15
            components.minute = 45
            
            XCTAssert(components.date?.timeInHours == 15.75)
        }
    }
    
    func testSecondsComponents() {
        
        measure { () -> Void in
            
            XCTAssert(Date.minuteInSeconds() == 60)
            XCTAssert(Date.hourInSeconds() == 3600)
            XCTAssert(Date.dayInSeconds() == 86400)
            XCTAssert(Date.weekInSeconds() == 604800)
        }
    }
    
    func testDaysBetweenDates() {
        
        measure { () -> Void in
            
            let daysBetween = 3
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601Calendar()
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
            
            XCTAssert(Date.daysBetween(fromDate: fromDate!, toDate: toDate!) == daysBetween)
        }
    }
    
    func testDaysRemainingInWeek() {
        
        measure { () -> Void in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601Calendar()
            components.year = 2016
            components.month = 2
            components.day = 26
            
            XCTAssert(components.date?.daysRemainingInWeek == 3)
            components.day = 28
            XCTAssert(components.date?.daysRemainingInWeek == 1)
        }
    }
    
    func testDaysInMonth() {
        
        measure { () -> Void in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601Calendar()
            components.year = 2016
            components.month = 2
            components.day = 26
            
            XCTAssert(components.date?.daysInMonth == 29)
        }
    }
    
    func testDaysRemainingInMonth() {
        
        measure { () -> Void in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601Calendar()
            components.year = 2016
            components.month = 2
            components.day = 26
            
            XCTAssert(components.date?.daysRemainingInMonth == 3)
        }
    }
    
    func testCompareDatesWithinMonth() {
        
        measure { () -> Void in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601Calendar()
            components.year = 2016
            components.month = 2
            components.day = 26
            
            let date = components.date!
            components.day = 28
            XCTAssert(date.isBefore(date: components.date!) == true)
            XCTAssert(date.isAfter(date: components.date!) == false)
            
            XCTAssert(date.compare(date: components.date!, option: .before, stripTime: false) == true)
            XCTAssert(date.compare(date: components.date!, option: .after, stripTime: false) == false)
            XCTAssert(date.compare(date: components.date!, option: .equalTo, stripTime: false) == false)
            XCTAssert(date.compare(date: components.date!, option: .beforeOrEqualTo, stripTime: false) == true)
            XCTAssert(date.compare(date: components.date!, option: .afterOrEqualTo, stripTime: false) == false)
            
            components.day = 26
            XCTAssert(date.compare(date: components.date!, option: .equalTo, stripTime: false) == true)
            XCTAssert(date.compare(date: components.date!, option: .beforeOrEqualTo, stripTime: false) == true)
            XCTAssert(date.compare(date: components.date!, option: .afterOrEqualTo, stripTime: false) == true)
            
            components.day = 11
            XCTAssert(date.isBefore(date: components.date!) == false)
            XCTAssert(date.isAfter(date: components.date!) == true)
            
            XCTAssert(date.compare(date: components.date!, option: .before, stripTime: false) == false)
            XCTAssert(date.compare(date: components.date!, option: .after, stripTime: false) == true)
            XCTAssert(date.compare(date: components.date!, option: .equalTo, stripTime: false) == false)
            XCTAssert(date.compare(date: components.date!, option: .beforeOrEqualTo, stripTime: false) == false)
            XCTAssert(date.compare(date: components.date!, option: .afterOrEqualTo, stripTime: false) == true)
        }
    }
    
    func testCompareDatesBetweenMonth() {
        
        measure { () -> Void in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601Calendar()
            components.year = 2016
            components.month = 2
            components.day = 26
            
            let date = components.date!
            components.month = 3
            components.day = 28
            XCTAssert(date.isBefore(date: components.date!) == true)
            XCTAssert(date.isAfter(date: components.date!) == false)
            
            XCTAssert(date.compare(date: components.date!, option: .before, stripTime: false) == true)
            XCTAssert(date.compare(date: components.date!, option: .after, stripTime: false) == false)
            XCTAssert(date.compare(date: components.date!, option: .equalTo, stripTime: false) == false)
            XCTAssert(date.compare(date: components.date!, option: .beforeOrEqualTo, stripTime: false) == true)
            XCTAssert(date.compare(date: components.date!, option: .afterOrEqualTo, stripTime: false) == false)
            
            components.day = 26
            XCTAssert(date.compare(date: components.date!, option: .equalTo, stripTime: false) == false)
            XCTAssert(date.compare(date: components.date!, option: .beforeOrEqualTo, stripTime: false) == true)
            XCTAssert(date.compare(date: components.date!, option: .afterOrEqualTo, stripTime: false) == false)
            
            components.month = 1
            XCTAssert(date.compare(date: components.date!, option: .equalTo, stripTime: false) == false)
            XCTAssert(date.compare(date: components.date!, option: .beforeOrEqualTo, stripTime: false) == false)
            XCTAssert(date.compare(date: components.date!, option: .afterOrEqualTo, stripTime: false) == true)
            
            components.day = 11
            XCTAssert(date.isBefore(date: components.date!) == false)
            XCTAssert(date.isAfter(date: components.date!) == true)
            
            XCTAssert(date.compare(date: components.date!, option: .before, stripTime: false) == false)
            XCTAssert(date.compare(date: components.date!, option: .after, stripTime: false) == true)
            XCTAssert(date.compare(date: components.date!, option: .equalTo, stripTime: false) == false)
            XCTAssert(date.compare(date: components.date!, option: .beforeOrEqualTo, stripTime: false) == false)
            XCTAssert(date.compare(date: components.date!, option: .afterOrEqualTo, stripTime: false) == true)
        }
    }
    
    func testCompareDatesBetweenYears() {
        
        measure { () -> Void in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601Calendar()
            components.year = 2016
            components.month = 2
            components.day = 26
            
            let date = components.date!
            components.year = 2017
            components.day = 28
            XCTAssert(date.isBefore(date: components.date!) == true)
            XCTAssert(date.isAfter(date: components.date!) == false)
            
            XCTAssert(date.compare(date: components.date!, option: .before, stripTime: false) == true)
            XCTAssert(date.compare(date: components.date!, option: .after, stripTime: false) == false)
            XCTAssert(date.compare(date: components.date!, option: .equalTo, stripTime: false) == false)
            XCTAssert(date.compare(date: components.date!, option: .beforeOrEqualTo, stripTime: false) == true)
            XCTAssert(date.compare(date: components.date!, option: .afterOrEqualTo, stripTime: false) == false)
            
            components.day = 26
            XCTAssert(date.compare(date: components.date!, option: .equalTo, stripTime: false) == false)
            XCTAssert(date.compare(date: components.date!, option: .beforeOrEqualTo, stripTime: false) == true)
            XCTAssert(date.compare(date: components.date!, option: .afterOrEqualTo, stripTime: false) == false)
            
            components.year = 2015
            XCTAssert(date.compare(date: components.date!, option: .equalTo, stripTime: false) == false)
            XCTAssert(date.compare(date: components.date!, option: .beforeOrEqualTo, stripTime: false) == false)
            XCTAssert(date.compare(date: components.date!, option: .afterOrEqualTo, stripTime: false) == true)
            
            components.day = 11
            XCTAssert(date.isBefore(date: components.date!) == false)
            XCTAssert(date.isAfter(date: components.date!) == true)
            
            XCTAssert(date.compare(date: components.date!, option: .before, stripTime: false) == false)
            XCTAssert(date.compare(date: components.date!, option: .after, stripTime: false) == true)
            XCTAssert(date.compare(date: components.date!, option: .equalTo, stripTime: false) == false)
            XCTAssert(date.compare(date: components.date!, option: .beforeOrEqualTo, stripTime: false) == false)
            XCTAssert(date.compare(date: components.date!, option: .afterOrEqualTo, stripTime: false) == true)
        }
    }
    
    func testStripTime() {
        
        measure { () -> Void in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601Calendar()
            components.year = 2016
            components.month = 2
            components.day = 26
            components.hour = 19
            components.minute = 12
            components.second = 43
            
            let date = components.date!
            let strippedDate = date.stripTime
            components.timeZone = TimeZone.utc()
            components.hour = 0
            components.minute = 0
            components.second = 0
            XCTAssert(strippedDate == components.date)
        }
    }
    
    func testDateByAddingDays() {
        
        measure { () -> Void in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601Calendar()
            components.year = 2016
            components.month = 2
            components.day = 26
            let date = components.date!
            
            XCTAssert(date.dateByAdding(days: 0) == date)
            components.day! += 3
            XCTAssert(date.dateByAdding(days: 3) == components.date)
            components.day! -= 5
            XCTAssert(date.dateByAdding(days: -2) == components.date)
        }
    }
    
    func testDateAt() {
        
        measure { () -> Void in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601Calendar()
            components.year = 2016
            components.month = 2
            components.day = 26
            components.hour = 19
            components.minute = 12
            components.second = 43
            let date = components.date!
            
            components.timeZone = TimeZone.utc()
            components.hour = 0
            components.minute = 0
            components.second = 0
            XCTAssert(date.dateAtStartOfDay == components.date)
            
            components.hour = 23
            components.minute = 59
            components.second = 59
            XCTAssert(date.dateAtEndOfDay == components.date)
        }
    }
    
    func testDateStrings() {
        
        var components = DateComponents()
        components.calendar = Calendar.iso8601Calendar()
        components.timeZone = TimeZone.utc()
        components.year = 2016
        components.month = 2
        components.day = 26
        components.hour = 19
        components.minute = 12
        components.second = 43
        let date = components.date!
        
        XCTAssert(date.dateTimeShortString == DateFormatter.localizedString(from: date, dateStyle: .shortStyle, timeStyle: .shortStyle))
        XCTAssert(date.dateShortString == DateFormatter.localizedString(from: date, dateStyle: .shortStyle, timeStyle: .noStyle))
        XCTAssert(date.dateMediumString == DateFormatter.localizedString(from: date, dateStyle: .mediumStyle, timeStyle: .noStyle))
        XCTAssert(date.dateFullString == DateFormatter.localizedString(from: date, dateStyle: .fullStyle, timeStyle: .noStyle))
        XCTAssert(date.timeShortString == DateFormatter.localizedString(from: date, dateStyle: .noStyle, timeStyle: .shortStyle))
        XCTAssert(date.fusDateString == "2016-02-26")
        XCTAssert(date.fusDateTimeString == "2016-02-26T20:12:43.000000Z")
        XCTAssert(date.dayString == "Friday")
        XCTAssert(date.dayShortString == "Fri")
        XCTAssert(date.monthString == "February")
        XCTAssert(date.monthShortString == "Feb")
        XCTAssert(date.yearString == "2016")
    }
    
}
