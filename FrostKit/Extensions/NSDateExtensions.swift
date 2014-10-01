//
//  NSDateExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright (c) 2014 Frostlight Solutions. All rights reserved.
//

import Foundation

public enum DateCompareType {
    case Before
    case After
    case EqualTo
    case BeforeOrEqualTo
    case AfterOrEqualTo
}

extension NSDate {
    
    // MARK: - Date Checks
    
    public var isYesterday: Bool {
        
        let date = NSDate.date().dateWithDays(-1)
        return self.compareTo(date: date)
    }
    
    public var isToday: Bool {
        return self.compareTo(date: NSDate.date())
    }
    
    public var isTomorrow: Bool {
        
        let date = NSDate.date().dateWithDays(1)
        return self.compareTo(date: date)
    }
    
    public var isWeekday: Bool {
        
        let calendar = NSCalendar.gregorianCalendar()
        let components = calendar.components(NSCalendarUnit.CalendarUnitWeekday, fromDate: self)
        let range = calendar.maximumRangeOfUnit(NSCalendarUnit.WeekdayCalendarUnit)
        if components.weekday == range.location || components.weekday == range.length {
            return false
        } else {
            return true
        }
    }
    
    public var isBeginingOfWeek: Bool {
        
        let calendar = NSCalendar.gregorianCalendar()
        let components = calendar.components(NSCalendarUnit.CalendarUnitWeekday, fromDate: self)
        if components.weekday == 2 { // Begining of week is Monday == 2
            return true
        } else {
            return false
        }
    }
    
    public var isEndOfWeek: Bool {
        
        let calendar = NSCalendar.gregorianCalendar()
        let components = calendar.components(NSCalendarUnit.CalendarUnitWeekday, fromDate: self)
        if components.weekday == 1 { // End of week is Sunday == 1
            return false
        } else {
            return false
        }
    }
    
    public var isBeginingOfMonth: Bool {
        
        let calendar = NSCalendar.gregorianCalendar()
        let components = calendar.components(NSCalendarUnit.CalendarUnitDay, fromDate: self)
        if components.day == 1 {
            return true
        } else {
            return false
        }
    }
    
    public var isEndOfMonth: Bool {
        
        let calendar = NSCalendar.gregorianCalendar()
        let components = calendar.components(NSCalendarUnit.CalendarUnitDay, fromDate: self)
        let range = calendar.rangeOfUnit(NSCalendarUnit.DayCalendarUnit, inUnit: NSCalendarUnit.MonthCalendarUnit, forDate: self)
        if components.day == range.length {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Duration
    
    public var day: Int {
        
        let calendar = NSCalendar.gregorianCalendar()
            let components = calendar.components(NSCalendarUnit.CalendarUnitDay, fromDate: self)
            return components.day
    }
    
    public var hour: Int {
        
        let calendar = NSCalendar.gregorianCalendar()
            let components = calendar.components(NSCalendarUnit.CalendarUnitHour, fromDate: self)
            return components.hour
    }
    
    public var minute: Int {
        
        let calendar = NSCalendar.gregorianCalendar()
            let components = calendar.components(NSCalendarUnit.CalendarUnitMinute, fromDate: self)
            return components.minute
    }
    
    public var timeInHours: NSTimeInterval {
        return NSTimeInterval(hour) + (NSTimeInterval(minute) / NSDate.minuteInSeconds())
    }
    
    public class func minuteInSeconds() -> NSTimeInterval {
        return 60.0
    }
    
    public class func hourInSeconds() -> NSTimeInterval {
        return minuteInSeconds() * 60.0
    }
    
    public class func dayInSeconds() -> NSTimeInterval {
        return hourInSeconds() * 24.0
    }
    
    public class func weekInSeconds() -> NSTimeInterval {
        return dayInSeconds() * 7.0
    }
    
    public class func daysBetweenDates(#fromDate: NSDate, toDate: NSDate) -> Int {
        
        var dateTo: NSDate?
        var dateFrom: NSDate?
        var duration: NSTimeInterval = 0
        
        let calendar = NSCalendar.gregorianCalendar()
        calendar.rangeOfUnit(NSCalendarUnit.DayCalendarUnit, startDate: &dateFrom, interval: &duration, forDate: toDate)
        calendar.rangeOfUnit(NSCalendarUnit.DayCalendarUnit, startDate: &dateTo, interval: &duration, forDate: fromDate)
        
        let components = calendar.components(NSCalendarUnit.DayCalendarUnit, fromDate: dateFrom!, toDate: dateTo!, options: NSCalendarOptions.WrapComponents)
        return components.day
    }
    
    public func daysRemainingInWeek() -> Int {
        
        let calendar = NSCalendar.gregorianCalendar()
        let components = calendar.components(NSCalendarUnit.CalendarUnitWeekday, fromDate: self)
        var weekdayOfDate = components.weekday
        // To make Monday == 1
        weekdayOfDate--
        if weekdayOfDate < 1 {
            weekdayOfDate = 7 + weekdayOfDate
        }
        return (7 - weekdayOfDate) + 1
    }
    
    public func daysInMonth() -> Int {
        
        let calendar = NSCalendar.gregorianCalendar()
        let range = calendar.rangeOfUnit(NSCalendarUnit.DayCalendarUnit, inUnit: NSCalendarUnit.MonthCalendarUnit, forDate: self)
        return range.length
    }
    
    public func daysRemainingInMonth() -> Int {
        
        let calendar = NSCalendar.gregorianCalendar()
        let components = calendar.components(NSCalendarUnit.CalendarUnitWeekday, fromDate: self)
        return (self.daysInMonth() - components.day) + 1
    }
    
    // MARK: - Date Comparison
    
    public func compareTo(#date: NSDate, option: DateCompareType = .EqualTo, stripTime: Bool = true) -> Bool {
        
        var compare: NSComparisonResult = .OrderedSame
        if stripTime == true {
            compare = self.stripTime().compare(date.stripTime())
        } else {
            compare = self.compare(date)
        }
        
        if compare == NSComparisonResult.OrderedAscending {
            
            if option == .Before || option == .After {
                return true
            }
        } else if compare == NSComparisonResult.OrderedDescending {
            
            if option == .After || option == .AfterOrEqualTo {
                return true
            }
        } else {
            
            if option == .EqualTo || option == .BeforeOrEqualTo || option == .AfterOrEqualTo {
                return true
            }
        }
        
        return false
    }
    
    public func isBefore(#date: NSDate) -> Bool {
        return compareTo(date: date, option: .Before)
    }
    
    public func isAfter(#date: NSDate) -> Bool {
        return compareTo(date: date, option: .After)
    }
    
    // MARK: -
    
    
    public func stripTime() -> NSDate {
        
        let calendar = NSCalendar.gregorianCalendar()
        let components = calendar.components((NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitYear), fromDate: self)
        components.timeZone = NSTimeZone.utc()
        if let date = calendar.dateFromComponents(components) {
            return date
        } else {
            println("Error: Failed to strip time from date \(self)")
            return self
        }
    }
    
    public func dateWithDays(days: Int) -> NSDate {
        
        let components = NSDateComponents()
        components.day = days
        
        let calendar = NSCalendar.gregorianCalendar()
        if let date = calendar.dateByAddingComponents(components, toDate: self, options: NSCalendarOptions.SearchBackwards) {
            return date
        } else {
            println("Error: Failed to add \(days) days to date \(self)")
            return self
        }
    }
    
}
