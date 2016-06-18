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
        
        measureBlock { () -> Void in
            
            let dateString = "2016-02-26"
            let date = NSDate.fusDate(dateString)
            
            let components = NSDateComponents()
            components.calendar = NSCalendar.iso8601Calendar()
            components.timeZone = NSTimeZone.utc()
            components.year = 2016
            components.month = 2
            components.day = 26
            
            XCTAssert(components.date == date)
        }
    }
    
    func testFusDateAndTime() {
        
        measureBlock { () -> Void in
            
            let dateString = "2016-02-26T15:24:48.000000Z"
            let date = NSDate.fusDate(dateString)
            
            let components = NSDateComponents()
            components.calendar = NSCalendar.iso8601Calendar()
            components.timeZone = NSTimeZone.utc()
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
    
    func testIsWeekday() {
        
        measureBlock { () -> Void in
            
            let components = NSDateComponents()
            components.calendar = NSCalendar.iso8601Calendar()
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
        
        measureBlock { () -> Void in
            
            let components = NSDateComponents()
            components.calendar = NSCalendar.iso8601Calendar()
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
        
        measureBlock { () -> Void in
            
            let components = NSDateComponents()
            components.calendar = NSCalendar.iso8601Calendar()
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
        
        measureBlock { () -> Void in
            
            let components = NSDateComponents()
            components.calendar = NSCalendar.iso8601Calendar()
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
        
        measureBlock { () -> Void in
            
            let components = NSDateComponents()
            components.calendar = NSCalendar.iso8601Calendar()
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
        
        measureBlock { () -> Void in
            
            let components = NSDateComponents()
            components.calendar = NSCalendar.iso8601Calendar()
            components.day = 26
            
            XCTAssert(components.date?.day == 26)
        }
    }
    
    func testHour() {
        
        measureBlock { () -> Void in
            
            let hour = 19
            let components = NSDateComponents()
            components.calendar = NSCalendar.iso8601Calendar()
            components.hour = hour
            
            XCTAssert(components.date?.hour == hour)
        }
    }
    
    func testMinute() {
        
        measureBlock { () -> Void in
            
            let minute = 47
            let components = NSDateComponents()
            components.calendar = NSCalendar.iso8601Calendar()
            components.minute = minute
            
            XCTAssert(components.date?.minute == minute)
        }
    }
    
    func testTimeInHours() {
        
        measureBlock { () -> Void in
            
            let components = NSDateComponents()
            components.calendar = NSCalendar.iso8601Calendar()
            components.hour = 15
            components.minute = 45
            
            XCTAssert(components.date?.timeInHours == 15.75)
        }
    }
    
    func testSecondsComponents() {
        
        measureBlock { () -> Void in
            
            XCTAssert(NSDate.minuteInSeconds() == 60)
            XCTAssert(NSDate.hourInSeconds() == 3600)
            XCTAssert(NSDate.dayInSeconds() == 86400)
            XCTAssert(NSDate.weekInSeconds() == 604800)
        }
    }
    
    func testDaysBetweenDates() {
        
        measureBlock { () -> Void in
            
            let daysBetween = 3
            
            let components = NSDateComponents()
            components.calendar = NSCalendar.iso8601Calendar()
            components.year = 2016
            components.month = 2
            components.day = 26
            
            let fromDate = components.date
            components.day += daysBetween
            let toDate = components.date
            
            XCTAssert(NSDate.daysBetweenDates(fromDate!, toDate: toDate!) == daysBetween)
        }
    }
    
    func testDaysRemainingInWeek() {
        
        measureBlock { () -> Void in
            
            let components = NSDateComponents()
            components.calendar = NSCalendar.iso8601Calendar()
            components.year = 2016
            components.month = 2
            components.day = 26
            
            XCTAssert(components.date?.daysRemainingInWeek == 3)
            components.day = 28
            XCTAssert(components.date?.daysRemainingInWeek == 1)
        }
    }
    
    func testDaysInMonth() {
        
        measureBlock { () -> Void in
            
            let components = NSDateComponents()
            components.calendar = NSCalendar.iso8601Calendar()
            components.year = 2016
            components.month = 2
            components.day = 26
            
            XCTAssert(components.date?.daysInMonth == 29)
        }
    }
    
    func testDaysRemainingInMonth() {
        
        measureBlock { () -> Void in
            
            let components = NSDateComponents()
            components.calendar = NSCalendar.iso8601Calendar()
            components.year = 2016
            components.month = 2
            components.day = 26
            
            XCTAssert(components.date?.daysRemainingInMonth == 3)
        }
    }
    
    func testCompareDatesWithinMonth() {
        
        measureBlock { () -> Void in
            
            let components = NSDateComponents()
            components.calendar = NSCalendar.iso8601Calendar()
            components.year = 2016
            components.month = 2
            components.day = 26
            
            let date = components.date!
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
        
        measureBlock { () -> Void in
            
            let components = NSDateComponents()
            components.calendar = NSCalendar.iso8601Calendar()
            components.year = 2016
            components.month = 2
            components.day = 26
            
            let date = components.date!
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
        
        measureBlock { () -> Void in
            
            let components = NSDateComponents()
            components.calendar = NSCalendar.iso8601Calendar()
            components.year = 2016
            components.month = 2
            components.day = 26
            
            let date = components.date!
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
        
        measureBlock { () -> Void in
            
            let components = NSDateComponents()
            components.calendar = NSCalendar.iso8601Calendar()
            components.year = 2016
            components.month = 2
            components.day = 26
            components.hour = 19
            components.minute = 12
            components.second = 43
            
            let date = components.date!
            let strippedDate = date.stripTime
            components.timeZone = NSTimeZone.utc()
            components.hour = 0
            components.minute = 0
            components.second = 0
            XCTAssert(strippedDate == components.date)
        }
    }
    
    func testDateByAddingDays() {
        
        measureBlock { () -> Void in
            
            let components = NSDateComponents()
            components.calendar = NSCalendar.iso8601Calendar()
            components.year = 2016
            components.month = 2
            components.day = 26
            let date = components.date!
            
            XCTAssert(date.dateByAddingDays(0) == date)
            components.day += 3
            XCTAssert(date.dateByAddingDays(3) == components.date)
            components.day -= 5
            XCTAssert(date.dateByAddingDays(-2) == components.date)
        }
    }
    
    func testDateAt() {
        
        measureBlock { () -> Void in
            
            let components = NSDateComponents()
            components.calendar = NSCalendar.iso8601Calendar()
            components.year = 2016
            components.month = 2
            components.day = 26
            components.hour = 19
            components.minute = 12
            components.second = 43
            let date = components.date!
            
            components.timeZone = NSTimeZone.utc()
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
        
        let components = NSDateComponents()
        components.calendar = NSCalendar.iso8601Calendar()
        components.timeZone = NSTimeZone.utc()
        components.year = 2016
        components.month = 2
        components.day = 26
        components.hour = 19
        components.minute = 12
        components.second = 43
        let date = components.date!
        
        XCTAssert(date.dateTimeShortString == NSDateFormatter.localizedStringFromDate(date, dateStyle: .ShortStyle, timeStyle: .ShortStyle))
        XCTAssert(date.dateShortString == NSDateFormatter.localizedStringFromDate(date, dateStyle: .ShortStyle, timeStyle: .NoStyle))
        XCTAssert(date.dateMediumString == NSDateFormatter.localizedStringFromDate(date, dateStyle: .MediumStyle, timeStyle: .NoStyle))
        XCTAssert(date.dateFullString == NSDateFormatter.localizedStringFromDate(date, dateStyle: .FullStyle, timeStyle: .NoStyle))
        XCTAssert(date.timeShortString == NSDateFormatter.localizedStringFromDate(date, dateStyle: .NoStyle, timeStyle: .ShortStyle))
        XCTAssert(date.fusDateString == "2016-02-26")
        XCTAssert(date.fusDateTimeString == "2016-02-26T20:12:43.000000Z")
        XCTAssert(date.dayString == "Friday")
        XCTAssert(date.dayShortString == "Fri")
        XCTAssert(date.monthString == "February")
        XCTAssert(date.monthShortString == "Feb")
        XCTAssert(date.yearString == "2016")
    }
    
}
