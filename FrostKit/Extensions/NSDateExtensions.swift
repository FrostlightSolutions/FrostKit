//
//  NSDateExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright (c) 2014-2015 James Barrow - Frostlight Solutions. All rights reserved.
//

import Foundation

///  Different ways to compare date
public enum DateCompareType {
    /// Date A is before Date B
    case Before
    /// Date A is after Date B
    case After
    /// Both dates are equal
    case EqualTo
    /// Date A is before or equal to Date B
    case BeforeOrEqualTo
    /// Date A is after or equal to Date B
    case AfterOrEqualTo
}

///
/// Extention functions for NSDate
///
extension NSDate {
    
    // MARK: - NSDate Creation
    
    /**
    Creates an NSDate from the FUS standard date format.
    
    :param: fusDateString The date string to make into an NSDate.
    
    :returns: The NSDate created from the passed in string or `nil` if it could not be created.
    */
    public class func fusDate(fusDateString: String) -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSSSSS'Z'"
        dateFormatter.timeZone = NSTimeZone.utc()
        dateFormatter.locale = NSLocale.systemLocale()
        return dateFormatter.dateFromString(fusDateString)
    }
    
    // MARK: - Date Checks
    
    /// `true` if the date is yesterday, `false` if it isn't.
    public var isYesterday: Bool {
        let date = NSDate().dateByAddingDays(-1)
        return compareToDate(date, option: DateCompareType.EqualTo)
    }
    
    /// `true` if the date is today, `false` if it isn't.
    public var isToday: Bool {
        return compareToDate(NSDate(), option: DateCompareType.EqualTo)
    }
    
    /// `true` if the date is tomorrow, `false` if it isn't.
    public var isTomorrow: Bool {
        let date = NSDate().dateByAddingDays(1)
        return compareToDate(date, option: DateCompareType.EqualTo)
    }
    
    /// `true` if the date is a weekday, `false` if it isn't.
    public var isWeekday: Bool {
        
        let calendar = NSCalendar.gregorianCalendar()
        let components = calendar.components(NSCalendarUnit.CalendarUnitWeekday, fromDate: self)
        let range = calendar.maximumRangeOfUnit(NSCalendarUnit.CalendarUnitWeekday)
        if components.weekday == range.location || components.weekday == range.length {
            return false
        } else {
            return true
        }
    }
    
    /// `true` if the date is the begining of the week, `false` if it isn't.
    public var isBeginingOfWeek: Bool {
        
        let calendar = NSCalendar.gregorianCalendar()
        let components = calendar.components(NSCalendarUnit.CalendarUnitWeekday, fromDate: self)
        if components.weekday == 2 { // Begining of week is Monday == 2
            return true
        } else {
            return false
        }
    }
    
    /// `true` if the date is the end of the week, `false` if it isn't.
    public var isEndOfWeek: Bool {
        
        let calendar = NSCalendar.gregorianCalendar()
        let components = calendar.components(NSCalendarUnit.CalendarUnitWeekday, fromDate: self)
        if components.weekday == 1 { // End of week is Sunday == 1
            return false
        } else {
            return false
        }
    }
    
    /// `true` if the date is the begining of the month, `false` if it isn't.
    public var isBeginingOfMonth: Bool {
        
        let calendar = NSCalendar.gregorianCalendar()
        let components = calendar.components(NSCalendarUnit.CalendarUnitDay, fromDate: self)
        if components.day == 1 {
            return true
        } else {
            return false
        }
    }
    
    /// `true` if the date is the end of the month, `false` if it isn't.
    public var isEndOfMonth: Bool {
        
        let calendar = NSCalendar.gregorianCalendar()
        let components = calendar.components(NSCalendarUnit.CalendarUnitDay, fromDate: self)
        let range = calendar.rangeOfUnit(NSCalendarUnit.CalendarUnitDay, inUnit: NSCalendarUnit.CalendarUnitMonth, forDate: self)
        if components.day == range.length {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Duration
    
    /// Returns the day of the date
    public var day: Int {
        
        let calendar = NSCalendar.gregorianCalendar()
            let components = calendar.components(NSCalendarUnit.CalendarUnitDay, fromDate: self)
            return components.day
    }
    
    /// Returns the hour of the date
    public var hour: Int {
        
        let calendar = NSCalendar.gregorianCalendar()
            let components = calendar.components(NSCalendarUnit.CalendarUnitHour, fromDate: self)
            return components.hour
    }
    
    /// Returns the minute of the date
    public var minute: Int {
        
        let calendar = NSCalendar.gregorianCalendar()
            let components = calendar.components(NSCalendarUnit.CalendarUnitMinute, fromDate: self)
            return components.minute
    }
    
    /// Returns the time of the date in hours
    public var timeInHours: NSTimeInterval {
        return NSTimeInterval(hour) + (NSTimeInterval(minute) / NSDate.minuteInSeconds())
    }
    
    /// Returns 1 minute in seconds `60`
    public class func minuteInSeconds() -> NSTimeInterval {
        return 60.0
    }
    
    /// Returns 1 hour in seconds `3600`
    public class func hourInSeconds() -> NSTimeInterval {
        return minuteInSeconds() * 60.0
    }
    
    /// Returns 1 day in seconds `86400`
    public class func dayInSeconds() -> NSTimeInterval {
        return hourInSeconds() * 24.0
    }
    
    /// Returns 1 week in seconds `604800`
    public class func weekInSeconds() -> NSTimeInterval {
        return dayInSeconds() * 7.0
    }
    
    /**
    Returns the number of days between two dates
    
    :param: fromDate    The first date to count days from
    :param: toDate      The second date to count days to
    
    :returns: The number of days beteen `fromDate` and `toDate`
    */
    public class func daysBetweenDates(#fromDate: NSDate, toDate: NSDate) -> Int {
        
        var dateTo: NSDate?
        var dateFrom: NSDate?
        var duration: NSTimeInterval = 0
        
        let calendar = NSCalendar.gregorianCalendar()
        calendar.rangeOfUnit(NSCalendarUnit.CalendarUnitDay, startDate: &dateFrom, interval: &duration, forDate: toDate)
        calendar.rangeOfUnit(NSCalendarUnit.CalendarUnitDay, startDate: &dateTo, interval: &duration, forDate: fromDate)
        
        let components = calendar.components(NSCalendarUnit.CalendarUnitDay, fromDate: dateFrom!, toDate: dateTo!, options: NSCalendarOptions.WrapComponents)
        return components.day
    }
    
    /**
    Returns the number of days left in the current week assuming Monday is the start of the week and inclusive of today
    
    :returns: The number of days left in the current week
    */
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
    
    /**
    Returns the number of days in the current month
    
    :returns: The number of days in the current month
    */
    public func daysInMonth() -> Int {
        
        let calendar = NSCalendar.gregorianCalendar()
        let range = calendar.rangeOfUnit(NSCalendarUnit.CalendarUnitDay, inUnit: NSCalendarUnit.CalendarUnitMonth, forDate: self)
        return range.length
    }
    
    /**
    Returns the number of days left in the month, inclusive of today
    
    :returns: The number of days left in the current month
    */
    public func daysRemainingInMonth() -> Int {
        
        let calendar = NSCalendar.gregorianCalendar()
        let components = calendar.components(NSCalendarUnit.CalendarUnitWeekday, fromDate: self)
        return (daysInMonth() - components.day) + 1
    }
    
    // MARK: - Date Comparison
    
    /**
    Compares two dates against each other depending on the date comparison type. This also take and extra variable that alows stripping of the time in the date.
    
    Note: When passing in a DateCompareType as an option, it must always be prefixed with DateCompareType. Passing in the base only prefixed with `.` will cause the current build of Xcode (6.1.1) to throw an compiler error (sometimes).
    
    :param: date        The date to compare against
    :param: option      The date comparison type defining the logic check. By default this is set to `EqualTo`.
    :param: stripTime   Whether the time should be stipped from the date before the comparison. By default this is set to `true`.
    
    :returns: `true` if the dates conform with the date comparison type check, `false` if not
    */
    public func compareToDate(date: NSDate, option: DateCompareType, stripTime: Bool = true) -> Bool {
        
        var compare: NSComparisonResult = .OrderedSame
        if stripTime == true {
            compare = self.stripTime().compare(date.stripTime())
        } else {
            compare = self.compare(date)
        }
        
        if compare == NSComparisonResult.OrderedAscending {
            
            if option == .Before || option == .BeforeOrEqualTo {
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
    
    /**
    Helper method for the `Before` date comparison type used in `compareToDate(date:option:striptime:)`. This with compare with the time stripped.
    
    :param: date        The date to compare against
    
    :returns: `true` if the comparison date is before date, `false` if not
    */
    public func isBefore(#date: NSDate) -> Bool {
        return compareToDate(date, option: DateCompareType.Before)
    }
    
    /**
    Helper method for the `After` date comparison type used in `compareToDate(date:option:striptime:)`. This with compare with the time stripped.
    
    :param: date        The date to compare against
    
    :returns: `true` if the comparison date is after date, `false` if not
    */
    public func isAfter(#date: NSDate) -> Bool {
        return compareToDate(date, option: DateCompareType.After)
    }
    
    // MARK: -
    
    /**
    Creates a new object which is a copy of the current date but with time stripped out (set to midnight)
    
    :returns: A copy of the current date with no time
    */
    public func stripTime() -> NSDate {
        
        let calendar = NSCalendar.gregorianCalendar()
        let components = calendar.components((NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitYear), fromDate: self)
        components.timeZone = NSTimeZone.utc()
        if let date = calendar.dateFromComponents(components) {
            return date
        } else {
            NSLog("Error: Failed to strip time from date \(self)")
            return self
        }
    }
    
    /**
    Creates a new object which is a copy of the current date but with a certain number of dats added to it
    
    :param: days        The number of days to add to the new date
    
    :returns: A copy of the current date `days` added to it
    */
    public func dateByAddingDays(days: Int) -> NSDate {
        
        let components = NSDateComponents()
        components.day = days
        
        let calendar = NSCalendar.gregorianCalendar()
        if let date = calendar.dateByAddingComponents(components, toDate: self, options: NSCalendarOptions.SearchBackwards) {
            return date
        } else {
            NSLog("Error: Failed to add \(days) days to date \(self)")
            return self
        }
    }
    
    // MARK: - Date Strings
    
    /**
    A helper method for getting a formatted string of the date and time in `ShortStyle`
    
    :retuerns: A string of formatted date time in `ShortStyle`
    */
    public func dateTimeShortString() -> String {
        return  NSDateFormatter.localizedStringFromDate(self, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
    }
    
    /**
    A helper method for getting a formatted string of the date in `ShortStyle`
    
    :retuerns: A string of formatted date in `ShortStyle`
    */
    public func dateShortString() -> String {
        return  NSDateFormatter.localizedStringFromDate(self, dateStyle: .ShortStyle, timeStyle: .NoStyle)
    }
    
    /**
    A helper method for getting a formatted string of the date in `FullStyle`
    
    :retuerns: A string of formatted date in `FullStyle`
    */
    public func dateFullString() -> String {
        return  NSDateFormatter.localizedStringFromDate(self, dateStyle: .FullStyle, timeStyle: .NoStyle)
    }
    
    /**
    A helper method for getting a formatted string of the time in `ShortStyle`
    
    :retuerns: A string of formatted time in `ShortStyle`
    */
    public func timeShortString() -> String {
        return  NSDateFormatter.localizedStringFromDate(self, dateStyle: .NoStyle, timeStyle: .ShortStyle)
    }
    
    /**
    Takes the format of a date and returns a formatted string of the date.
    
    :param: format The format of the date string to return.
    
    :returns: The formatted date string.
    */
    public func dateStringFromFormat(format: String) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter.stringFromDate(self)
    }
    
    /**
    Returns the date's day of the week string. i.e. Monday
    
    :returns: The weekday string.
    */
    public func dayString() -> String {
        return dateStringFromFormat("EEEE")
    }
    
    /**
    Returns the date's day of the week as a short string. i.e. Mon
    
    :returns: The short weekday string.
    */
    public func dayShortString() -> String {
        return dateStringFromFormat("EEE")
    }
    
    /**
    Returns the date's month string. i.e. September
    
    :returns: The month string.
    */
    public func monthString() -> String {
        return dateStringFromFormat("MMMM")
    }
    
    /**
    Returns the date's month short string. i.e. Sept
    
    :returns: The month short string.
    */
    public func monthShortString() -> String {
        return dateStringFromFormat("MMM")
    }
    
}
