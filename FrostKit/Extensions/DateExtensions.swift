//
//  DateExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright (c) 2014-2015 James Barrow - Frostlight Solutions. All rights reserved.
//

import Foundation

///  Different ways to compare date
public enum DateCompareType {
    /// Date A is before Date B
    case before
    /// Date A is after Date B
    case after
    /// Both dates are equal
    case equalTo
    /// Date A is before or equal to Date B
    case beforeOrEqualTo
    /// Date A is after or equal to Date B
    case afterOrEqualTo
}

/// Most common component flags
private let componentFlags: NSCalendarUnit = ([.year, .month, .day, .weekOfMonth, .hour, .minute, .second, .weekday, .weekdayOrdinal])

///
/// Extention functions for NSDate
///
extension NSDate {
    
    // MARK: - NSDate Creation
    
    /**
    Creates an NSDate from the FUS standard date format.
    
    - parameter fusDateString: The date string to make into an NSDate in the format of `yyyy-MM-dd` or `yyyy-MM-ddTHH:mm:ss.SSSSSSZ`.
    
    - returns: The NSDate created from the passed in string or `nil` if it could not be created.
    */
    public class func fusDate(from fusDateString: String) -> NSDate? {
        var format = "yyyy'-'MM'-'dd"
        if fusDateString.characters.count > 10 {
            format += "'T'HH':'mm':'ss'.'SSSSSS'Z'"
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = NSTimeZone.utc()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return dateFormatter.date(from: fusDateString)
    }
    
    /**
     Creates an NSDate from the iso8601 standard date format.
     
     - parameter iso8601String: The date string to make into an NSDate in the format of `yyyy-MM-ddTHH:mm:ssZ`.
     
     - returns: The NSDate created from the passed in string or `nil` if it could not be created.
     */
    public class func iso8601Date(from iso8601String: String) -> NSDate? {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        dateFormatter.timeZone = NSTimeZone.utc()
        dateFormatter.locale = NSLocale.autoupdatingCurrent()
        return dateFormatter.date(from: iso8601String)
    }
    
    // MARK: - Date Checks
    
    /// `true` if the date is yesterday, `false` if it isn't.
    public var isYesterday: Bool {
        let date = NSDate().dateByAdding(days: -1)
        return compare(date: date, option: .equalTo)
    }
    
    /// `true` if the date is today, `false` if it isn't.
    public var isToday: Bool {
        return compare(date: NSDate(), option: .equalTo)
    }
    
    /// `true` if the date is tomorrow, `false` if it isn't.
    public var isTomorrow: Bool {
        let date = NSDate().dateByAdding(days: 1)
        return compare(date: date, option: .equalTo)
    }
    
    /// `true` if the date is a weekday, `false` if it isn't.
    public var isWeekday: Bool {
        
        let calendar = NSCalendar.iso8601Calendar()
        let components = calendar.components(.weekday, from: self)
        let range = calendar.maximumRange(of: .weekday)
        
        if components.weekday == range.location || components.weekday == range.length {
            return false
        }
        return true
    }
    
    /// `true` if the date is the begining of the week, `false` if it isn't. Begining of week is Monday.
    public var isBeginingOfWeek: Bool {
        
        let calendar = NSCalendar.iso8601Calendar()
        let components = calendar.components(.weekday, from: self)
        return components.weekday == 2 // Begining of week is Monday == 2
    }
    
    /// `true` if the date is the end of the week, `false` if it isn't. End of week is Sunday.
    public var isEndOfWeek: Bool {
        
        let calendar = NSCalendar.iso8601Calendar()
        let components = calendar.components(.weekday, from: self)
        return components.weekday == 1 // End of week is Sunday == 1
    }
    
    /// `true` if the date is the begining of the month, `false` if it isn't.
    public var isBeginingOfMonth: Bool {
        
        let calendar = NSCalendar.iso8601Calendar()
        let components = calendar.components(.day, from: self)
        return components.day == 1
    }
    
    /// `true` if the date is the end of the month, `false` if it isn't.
    public var isEndOfMonth: Bool {
        
        let calendar = NSCalendar.iso8601Calendar()
        let components = calendar.components(.day, from: self)
        let range = calendar.range(of: .day, in: .month, for: self)
        return components.day == range.length
    }
    
    // MARK: - Duration
    
    /// Returns the day of the date
    public var day: Int {
        
        let calendar = NSCalendar.iso8601Calendar()
        let components = calendar.components(.day, from: self)
        return components.day
    }
    
    /// Returns the hour of the date
    public var hour: Int {
        
        let calendar = NSCalendar.iso8601Calendar()
        let components = calendar.components(.hour, from: self)
        return components.hour
    }
    
    /// Returns the minute of the date
    public var minute: Int {
        
        let calendar = NSCalendar.iso8601Calendar()
        let components = calendar.components(.minute, from: self)
        return components.minute
    }
    
    /// Returns the time of the date in hours
    public var timeInHours: NSTimeInterval {
        return NSTimeInterval(hour) + (NSTimeInterval(minute) / 60)
    }
    
    /// Returns 1 minute in seconds `60`
    public class func minuteInSeconds() -> NSTimeInterval {
        return 60
    }
    
    /// Returns 1 hour in seconds `3600`
    public class func hourInSeconds() -> NSTimeInterval {
        return minuteInSeconds() * 60
    }
    
    /// Returns 1 day in seconds `86400`
    public class func dayInSeconds() -> NSTimeInterval {
        return hourInSeconds() * 24
    }
    
    /// Returns 1 week in seconds `604800`
    public class func weekInSeconds() -> NSTimeInterval {
        return dayInSeconds() * 7
    }
    
    /**
    Returns the number of days between two dates
    
    - parameter fromDate:    The first date to count days from
    - parameter toDate:      The second date to count days to
    
    - returns: The number of days beteen `fromDate` and `toDate`
    */
    public class func daysBetweenDates(fromDate: NSDate, toDate: NSDate) -> Int {
        
        var dateFrom: NSDate?
        var dateTo: NSDate?
        
        let calendar = NSCalendar.iso8601Calendar()
        calendar.range(of: .day, start: &dateTo, interval: nil, for: toDate)
        calendar.range(of: .day, start: &dateFrom, interval: nil, for: fromDate)
        
        let components = calendar.components(.day, from: dateFrom!, to: dateTo!, options: .wrapComponents)
        return components.day
    }
    
    /// Returns the number of days left in the current week assuming Monday is the start of the week and inclusive of today
    public var daysRemainingInWeek: Int {
        
        let calendar = NSCalendar.iso8601Calendar()
        let components = calendar.components(.weekday, from: self)
        var weekdayOfDate = components.weekday
        // To make Monday == 1
        weekdayOfDate -= 1
        if weekdayOfDate < 1 {
            weekdayOfDate = 7 + weekdayOfDate
        }
        return (7 - weekdayOfDate) + 1
    }
    
    /// Returns the number of days in the current month
    public var daysInMonth: Int {
        
        let calendar = NSCalendar.iso8601Calendar()
        let range = calendar.range(of: .day, in: .month, for: self)
        return range.length
    }
    
    /// Returns the number of days left in the month, inclusive of today
    public var daysRemainingInMonth: Int {
        
        let calendar = NSCalendar.iso8601Calendar()
        let components = calendar.components(.day, from: self)
        return (daysInMonth - components.day)
    }
    
    // MARK: - Date Comparison
    
    /**
    Compares two dates against each other depending on the date comparison type. This also take and extra variable that alows stripping of the time in the date.
    
    Note: When passing in a DateCompareType as an option, it must always be prefixed with DateCompareType. Passing in the base only prefixed with `.` will cause the current build of Xcode (6.1.1) to throw an compiler error (sometimes).
    
    - parameter date:        The date to compare against
    - parameter option:      The date comparison type defining the logic check. By default this is set to `EqualTo`.
    - parameter stripTime:   Whether the time should be stipped from the date before the comparison. By default this is set to `true`.
    
    - returns: `true` if the dates conform with the date comparison type check, `false` if not
    */
    public func compare(date: NSDate, option: DateCompareType, stripTime: Bool = true) -> Bool {
        
        var compare: NSComparisonResult = .orderedSame
        if stripTime == true {
            compare = self.stripTime.compare(date.stripTime)
        } else {
            compare = self.compare(date)
        }
        
        if compare == NSComparisonResult.orderedAscending {
            
            if option == .before || option == .beforeOrEqualTo {
                return true
            }
        } else if compare == NSComparisonResult.orderedDescending {
            
            if option == .after || option == .afterOrEqualTo {
                return true
            }
        } else {
            
            if option == .equalTo || option == .beforeOrEqualTo || option == .afterOrEqualTo {
                return true
            }
        }
        
        return false
    }
    
    /**
    Helper method for the `Before` date comparison type used in `compareToDate(date:option:striptime:)`. This with compare with the time stripped.
    
    - parameter date:        The date to compare against
    
    - returns: `true` if the comparison date is before date, `false` if not
    */
    public func isBefore(date: NSDate) -> Bool {
        return compare(date: date, option: .before)
    }
    
    /**
    Helper method for the `After` date comparison type used in `compareToDate(date:option:striptime:)`. This with compare with the time stripped.
    
    - parameter date:        The date to compare against
    
    - returns: `true` if the comparison date is after date, `false` if not
    */
    public func isAfter(date: NSDate) -> Bool {
        return compare(date: date, option: .after)
    }
    
    // MARK: -
    
    /// Creates a new object which is a copy of the current date but with time stripped out (set to midnight)
    public var stripTime: NSDate {
        
        let calendar = NSCalendar.iso8601Calendar()
        let components = calendar.components(([.day, .month, .year]), from: self)
        components.timeZone = NSTimeZone.utc()
        return calendar.date(from: components)!
    }
    
    /**
    Creates a new object which is a copy of the current date but with a certain number of dats added to it
    
    - parameter days:        The number of days to add to the new date
    
    - returns: A copy of the current date `days` added to it
    */
    public func dateByAdding(days: Int) -> NSDate {
        
        if days == 0 {
            return self
        }
        
        let components = NSDateComponents()
        components.day = days
        
        let calendar = NSCalendar.iso8601Calendar()
        return calendar.date(byAdding: components, to: self, options: .searchBackwards)!
    }
    
    /// Returns a date with the time at the start of the day, while preserving the time zone.
    public var dateAtStartOfDay: NSDate {
        
        let calendar = NSCalendar.iso8601Calendar()
        let components = calendar.components(componentFlags, from: self)
        components.timeZone = NSTimeZone.utc()
        components.hour = 0
        components.minute = 0
        components.second = 0
        return calendar.date(from: components)!
    }
    
    /// Returns a date with the time at the end of the day, while preserving the time zone.
    public var dateAtEndOfDay: NSDate {
        
        let calendar = NSCalendar.iso8601Calendar()
        let components = calendar.components(componentFlags, from: self)
        components.timeZone = NSTimeZone.utc()
        components.hour = 23
        components.minute = 59
        components.second = 59
        return calendar.date(from: components)!
    }
    
    // MARK: - Date Strings
    
    /// A helper method for getting a formatted string of the date and time in `ShortStyle`
    public var dateTimeShortString: String {
        return  NSDateFormatter.localizedString(from: self, dateStyle: .shortStyle, timeStyle: .shortStyle)
    }
    
    /// A helper method for getting a formatted string of the date in `ShortStyle`
    public var dateShortString: String {
        return  NSDateFormatter.localizedString(from: self, dateStyle: .shortStyle, timeStyle: .noStyle)
    }
    
    /// A helper method for getting a formatted string of the date in `MediumStyle`
    public var dateMediumString: String {
        return  NSDateFormatter.localizedString(from: self, dateStyle: .mediumStyle, timeStyle: .noStyle)
    }
    
    /// A helper method for getting a formatted string of the date in `FullStyle`
    public var dateFullString: String {
        return  NSDateFormatter.localizedString(from: self, dateStyle: .fullStyle, timeStyle: .noStyle)
    }
    
    /// A helper method for getting a formatted string of the time in `ShortStyle`
    public var timeShortString: String {
        return  NSDateFormatter.localizedString(from: self, dateStyle: .noStyle, timeStyle: .shortStyle)
    }
    
    /// A helpter method for getting a formatted string of the date in the FUS set format.
    public var fusDateString: String {
        return dateString(fromFormat: "yyyy'-'MM'-'dd")
    }
    
    /// A helpter method for getting a formatted string of the date and time in the FUS set format.
    public var fusDateTimeString: String {
        let locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return dateString(fromFormat: "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSSSSS'Z'", locale: locale)
    }
    
    /**
    Takes the format of a date and returns a formatted string of the date.
    
    - parameter format: The format of the date string to return.
    - parameter locale: The locale to set to the date formatter (optional).
    
    - returns: The formatted date string.
    */
    public func dateString(fromFormat format: String, locale: NSLocale? = nil) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        formatter.locale = locale
        return formatter.string(from: self)
    }
    
    /// Returns the date's day of the week string. i.e. Monday
    public var dayString: String {
        return dateString(fromFormat: "EEEE")
    }
    
    /// Returns the date's day of the week as a short string. i.e. Mon
    public var dayShortString: String {
        return dateString(fromFormat: "EEE")
    }
    
    /// Returns the date's month string. i.e. September
    public var monthString: String {
        return dateString(fromFormat: "MMMM")
    }
    
    /// Returns the date's month short string. i.e. Sept
    public var monthShortString: String {
        return dateString(fromFormat: "MMM")
    }
    
    /// Returns the date's year string. i.e. 2015
    public var yearString: String {
        return dateString(fromFormat: "Y")
    }
    
}
