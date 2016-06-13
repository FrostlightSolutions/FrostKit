//
//  DateExtensionsTests.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright (c) 2014-2015 James Barrow - Frostlight Solutions. All rights reserved.
//

import XCTest

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
            let date = Date.fusDate(dateString)
            
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
            let date = Date.fusDate(dateString)
            
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
            XCTAssert((components as NSDateComponents).date?.isWeekday == true)
            components.day = 23 // Tuesday
            XCTAssert((components as NSDateComponents).date?.isWeekday == true)
            components.day = 24 // Wednesday
            XCTAssert((components as NSDateComponents).date?.isWeekday == true)
            components.day = 25 // Thursday
            XCTAssert((components as NSDateComponents).date?.isWeekday == true)
            components.day = 26 // Friday
            XCTAssert((components as NSDateComponents).date?.isWeekday == true)
            components.day = 27 // Saturday
            XCTAssert((components as NSDateComponents).date?.isWeekday == false)
            components.day = 28 // Sunday
            XCTAssert((components as NSDateComponents).date?.isWeekday == false)
        }
    }
    
    func testIsBeginingOfWeek () {
        
        measure { () -> Void in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601Calendar()
            components.year = 2016
            components.month = 2
            
            components.day = 22 // Monday
            XCTAssert((components as NSDateComponents).date?.isBeginingOfWeek == true)
            components.day = 23 // Tuesday
            XCTAssert((components as NSDateComponents).date?.isBeginingOfWeek == false)
            components.day = 24 // Wednesday
            XCTAssert((components as NSDateComponents).date?.isBeginingOfWeek == false)
            components.day = 25 // Thursday
            XCTAssert((components as NSDateComponents).date?.isBeginingOfWeek == false)
            components.day = 26 // Friday
            XCTAssert((components as NSDateComponents).date?.isBeginingOfWeek == false)
            components.day = 27 // Saturday
            XCTAssert((components as NSDateComponents).date?.isBeginingOfWeek == false)
            components.day = 28 // Sunday
            XCTAssert((components as NSDateComponents).date?.isBeginingOfWeek == false)
        }
    }
    
    func testIsEndOfWeek () {
        
        measure { () -> Void in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601Calendar()
            components.year = 2016
            components.month = 2
            
            components.day = 22 // Monday
            XCTAssert((components as NSDateComponents).date?.isEndOfWeek == false)
            components.day = 23 // Tuesday
            XCTAssert((components as NSDateComponents).date?.isEndOfWeek == false)
            components.day = 24 // Wednesday
            XCTAssert((components as NSDateComponents).date?.isEndOfWeek == false)
            components.day = 25 // Thursday
            XCTAssert((components as NSDateComponents).date?.isEndOfWeek == false)
            components.day = 26 // Friday
            XCTAssert((components as NSDateComponents).date?.isEndOfWeek == false)
            components.day = 27 // Saturday
            XCTAssert((components as NSDateComponents).date?.isEndOfWeek == false)
            components.day = 28 // Sunday
            XCTAssert((components as NSDateComponents).date?.isEndOfWeek == true)
        }
    }
    
    func testIsBeginingOfMonth () {
        
        measure { () -> Void in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601Calendar()
            components.year = 2016
            components.month = 2
            
            components.day = 29
            XCTAssert((components as NSDateComponents).date?.isBeginingOfMonth == false)
            components.month = 3
            components.day = 1
            XCTAssert((components as NSDateComponents).date?.isBeginingOfMonth == true)
            components.day = 2
            XCTAssert((components as NSDateComponents).date?.isBeginingOfMonth == false)
        }
    }
    
    func testIsEndOfMonth () {
        
        measure { () -> Void in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601Calendar()
            components.year = 2016
            components.month = 2
            
            components.day = 28
            XCTAssert((components as NSDateComponents).date?.isEndOfMonth == false)
            components.day = 29
            XCTAssert((components as NSDateComponents).date?.isEndOfMonth == true)
            components.month = 3
            components.day = 1
            XCTAssert((components as NSDateComponents).date?.isEndOfMonth == false)
        }
    }
    
    func testDay() {
        
        measure { () -> Void in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601Calendar()
            components.day = 26
            
            XCTAssert((components as NSDateComponents).date?.day == 26)
        }
    }
    
    func testHour() {
        
        measure { () -> Void in
            
            let hour = 19
            var components = DateComponents()
            components.calendar = Calendar.iso8601Calendar()
            components.hour = hour
            
            XCTAssert((components as NSDateComponents).date?.hour == hour)
        }
    }
    
    func testMinute() {
        
        measure { () -> Void in
            
            let minute = 47
            var components = DateComponents()
            components.calendar = Calendar.iso8601Calendar()
            components.minute = minute
            
            XCTAssert((components as NSDateComponents).date?.minute == minute)
        }
    }
    
    func testTimeInHours() {
        
        measure { () -> Void in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601Calendar()
            components.hour = 15
            components.minute = 45
            
            XCTAssert((components as NSDateComponents).date?.timeInHours == 15.75)
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
            
            let fromDate = (components as NSDateComponents).date
            components.day += daysBetween
            let toDate = (components as NSDateComponents).date
            
            XCTAssert(Date.daysBetweenDates(fromDate!, toDate: toDate!) == daysBetween)
        }
    }
    
    func testDaysRemainingInWeek() {
        
        measure { () -> Void in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601Calendar()
            components.year = 2016
            components.month = 2
            components.day = 26
            
            XCTAssert((components as NSDateComponents).date?.daysRemainingInWeek == 3)
            components.day = 28
            XCTAssert((components as NSDateComponents).date?.daysRemainingInWeek == 1)
        }
    }
    
    func testDaysInMonth() {
        
        measure { () -> Void in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601Calendar()
            components.year = 2016
            components.month = 2
            components.day = 26
            
            XCTAssert((components as NSDateComponents).date?.daysInMonth == 29)
        }
    }
    
    func testDaysRemainingInMonth() {
        
        measure { () -> Void in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601Calendar()
            components.year = 2016
            components.month = 2
            components.day = 26
            
            XCTAssert((components as NSDateComponents).date?.daysRemainingInMonth == 3)
        }
    }
    
    func testCompareDatesWithinMonth() {
        
        measure { () -> Void in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601Calendar()
            components.year = 2016
            components.month = 2
            components.day = 26
            
            let date = (components as NSDateComponents).date!
            components.day = 28
            XCTAssert(date.isBefore(components.date!) == true)
            XCTAssert(date.isAfter(components.date!) == false)
            
            XCTAssert(date.compareToDate(components.date!, option: .Before, stripTime: false) == true)
            XCTAssert(date.compareToDate(components.date!, option: .After, stripTime: false) == false)
            XCTAssert(date.compareToDate(components.date!, option: .EqualTo, stripTime: false) == false)
            XCTAssert(date.compareToDate(components.date!, option: .BeforeOrEqualTo, stripTime: false) == true)
            XCTAssert(date.compareToDate(components.date!, option: .AfterOrEqualTo, stripTime: false) == false)
            
            components.day = 26
            XCTAssert(date.compareToDate(components.date!, option: .EqualTo, stripTime: false) == true)
            XCTAssert(date.compareToDate(components.date!, option: .BeforeOrEqualTo, stripTime: false) == true)
            XCTAssert(date.compareToDate(components.date!, option: .AfterOrEqualTo, stripTime: false) == true)
            
            components.day = 11
            XCTAssert(date.isBefore(components.date!) == false)
            XCTAssert(date.isAfter(components.date!) == true)
            
            XCTAssert(date.compareToDate(components.date!, option: .Before, stripTime: false) == false)
            XCTAssert(date.compareToDate(components.date!, option: .After, stripTime: false) == true)
            XCTAssert(date.compareToDate(components.date!, option: .EqualTo, stripTime: false) == false)
            XCTAssert(date.compareToDate(components.date!, option: .BeforeOrEqualTo, stripTime: false) == false)
            XCTAssert(date.compareToDate(components.date!, option: .AfterOrEqualTo, stripTime: false) == true)
        }
    }
    
    func testCompareDatesBetweenMonth() {
        
        measure { () -> Void in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601Calendar()
            components.year = 2016
            components.month = 2
            components.day = 26
            
            let date = (components as NSDateComponents).date!
            components.month = 3
            components.day = 28
            XCTAssert(date.isBefore(components.date!) == true)
            XCTAssert(date.isAfter(components.date!) == false)
            
            XCTAssert(date.compareToDate(components.date!, option: .Before, stripTime: false) == true)
            XCTAssert(date.compareToDate(components.date!, option: .After, stripTime: false) == false)
            XCTAssert(date.compareToDate(components.date!, option: .EqualTo, stripTime: false) == false)
            XCTAssert(date.compareToDate(components.date!, option: .BeforeOrEqualTo, stripTime: false) == true)
            XCTAssert(date.compareToDate(components.date!, option: .AfterOrEqualTo, stripTime: false) == false)
            
            components.day = 26
            XCTAssert(date.compareToDate(components.date!, option: .EqualTo, stripTime: false) == false)
            XCTAssert(date.compareToDate(components.date!, option: .BeforeOrEqualTo, stripTime: false) == true)
            XCTAssert(date.compareToDate(components.date!, option: .AfterOrEqualTo, stripTime: false) == false)
            
            components.month = 1
            XCTAssert(date.compareToDate(components.date!, option: .EqualTo, stripTime: false) == false)
            XCTAssert(date.compareToDate(components.date!, option: .BeforeOrEqualTo, stripTime: false) == false)
            XCTAssert(date.compareToDate(components.date!, option: .AfterOrEqualTo, stripTime: false) == true)
            
            components.day = 11
            XCTAssert(date.isBefore(components.date!) == false)
            XCTAssert(date.isAfter(components.date!) == true)
            
            XCTAssert(date.compareToDate(components.date!, option: .Before, stripTime: false) == false)
            XCTAssert(date.compareToDate(components.date!, option: .After, stripTime: false) == true)
            XCTAssert(date.compareToDate(components.date!, option: .EqualTo, stripTime: false) == false)
            XCTAssert(date.compareToDate(components.date!, option: .BeforeOrEqualTo, stripTime: false) == false)
            XCTAssert(date.compareToDate(components.date!, option: .AfterOrEqualTo, stripTime: false) == true)
        }
    }
    
    func testCompareDatesBetweenYears() {
        
        measure { () -> Void in
            
            var components = DateComponents()
            components.calendar = Calendar.iso8601Calendar()
            components.year = 2016
            components.month = 2
            components.day = 26
            
            let date = (components as NSDateComponents).date!
            components.year = 2017
            components.day = 28
            XCTAssert(date.isBefore(components.date!) == true)
            XCTAssert(date.isAfter(components.date!) == false)
            
            XCTAssert(date.compareToDate(components.date!, option: .Before, stripTime: false) == true)
            XCTAssert(date.compareToDate(components.date!, option: .After, stripTime: false) == false)
            XCTAssert(date.compareToDate(components.date!, option: .EqualTo, stripTime: false) == false)
            XCTAssert(date.compareToDate(components.date!, option: .BeforeOrEqualTo, stripTime: false) == true)
            XCTAssert(date.compareToDate(components.date!, option: .AfterOrEqualTo, stripTime: false) == false)
            
            components.day = 26
            XCTAssert(date.compareToDate(components.date!, option: .EqualTo, stripTime: false) == false)
            XCTAssert(date.compareToDate(components.date!, option: .BeforeOrEqualTo, stripTime: false) == true)
            XCTAssert(date.compareToDate(components.date!, option: .AfterOrEqualTo, stripTime: false) == false)
            
            components.year = 2015
            XCTAssert(date.compareToDate(components.date!, option: .EqualTo, stripTime: false) == false)
            XCTAssert(date.compareToDate(components.date!, option: .BeforeOrEqualTo, stripTime: false) == false)
            XCTAssert(date.compareToDate(components.date!, option: .AfterOrEqualTo, stripTime: false) == true)
            
            components.day = 11
            XCTAssert(date.isBefore(components.date!) == false)
            XCTAssert(date.isAfter(components.date!) == true)
            
            XCTAssert(date.compareToDate(components.date!, option: .Before, stripTime: false) == false)
            XCTAssert(date.compareToDate(components.date!, option: .After, stripTime: false) == true)
            XCTAssert(date.compareToDate(components.date!, option: .EqualTo, stripTime: false) == false)
            XCTAssert(date.compareToDate(components.date!, option: .BeforeOrEqualTo, stripTime: false) == false)
            XCTAssert(date.compareToDate(components.date!, option: .AfterOrEqualTo, stripTime: false) == true)
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
            
            let date = (components as NSDateComponents).date!
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
            let date = (components as NSDateComponents).date!
            
            XCTAssert(date.dateByAddingDays(0) == date)
            components.day += 3
            XCTAssert(date.dateByAddingDays(3) == components.date)
            components.day -= 5
            XCTAssert(date.dateByAddingDays(-2) == components.date)
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
            let date = (components as NSDateComponents).date!
            
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
        let date = (components as NSDateComponents).date!
        
        XCTAssert(date.dateTimeShortString == DateFormatter.localizedStringFromDate(date, dateStyle: .ShortStyle, timeStyle: .ShortStyle))
        XCTAssert(date.dateShortString == DateFormatter.localizedStringFromDate(date, dateStyle: .ShortStyle, timeStyle: .NoStyle))
        XCTAssert(date.dateMediumString == DateFormatter.localizedStringFromDate(date, dateStyle: .MediumStyle, timeStyle: .NoStyle))
        XCTAssert(date.dateFullString == DateFormatter.localizedStringFromDate(date, dateStyle: .FullStyle, timeStyle: .NoStyle))
        XCTAssert(date.timeShortString == DateFormatter.localizedStringFromDate(date, dateStyle: .NoStyle, timeStyle: .ShortStyle))
        XCTAssert(date.fusDateString == "2016-02-26")
        XCTAssert(date.fusDateTimeString == "2016-02-26T20:12:43.000000Z")
        XCTAssert(date.dayString == "Friday")
        XCTAssert(date.dayShortString == "Fri")
        XCTAssert(date.monthString == "February")
        XCTAssert(date.monthShortString == "Feb")
        XCTAssert(date.yearString == "2016")
    }
    
}
