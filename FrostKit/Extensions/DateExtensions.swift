//
//  DateExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright © 2014 - 2017 James Barrow - Frostlight Solutions. All rights reserved.
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

///
/// Extention functions for Date
///
extension Date {
    
    // MARK: - Date Creation
    
    /**
    Creates an Date from the FUS standard date format.
     
    - parameter fusDateString: The date string to make into an Date in the format of `yyyy-MM-dd` or `yyyy-MM-ddTHH:mm:ss.SSSSSSZ`.
     
    - returns: The Date created from the passed in string or `nil` if it could not be created.
    */
    public static func fusDate(from fusDateString: String) -> Date? {
        
        var format = "yyyy'-'MM'-'dd"
        if fusDateString.count > 10 {
            format += "'T'HH':'mm':'ss'.'SSSSSS'Z'"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone.utc
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: fusDateString)
    }
    
    /**
     Creates an Date from the iso8601 standard date format.
     
     - parameter iso8601String: The date string to make into an Date in the format of `yyyy-MM-ddTHH:mm:ssZ`.
     
     - returns: The Date created from the passed in string or `nil` if it could not be created.
     */
    public static func iso8601Date(from iso8601String: String) -> Date? {
        
        if #available(iOSApplicationExtension 10.0, watchOSApplicationExtension 3.0, tvOSApplicationExtension 10.0, OSXApplicationExtension 10.12, *) {
            
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.timeZone = TimeZone.utc
            return dateFormatter.date(from: iso8601String)
            
        } else {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
            dateFormatter.timeZone = TimeZone.utc
            dateFormatter.locale = Locale.autoupdatingCurrent
            return dateFormatter.date(from: iso8601String)
        }
    }
    
    // MARK: - Date Checks
    
    /// `true` if the date is yesterday, `false` if it isn't.
    public var isYesterday: Bool {
        
        let calendar = Calendar.iso8601
        return calendar.isDateInYesterday(self)
    }
    
    /// `true` if the date is today, `false` if it isn't.
    public var isToday: Bool {
        
        let calendar = Calendar.iso8601
        return calendar.isDateInToday(self)
    }
    
    /// `true` if the date is tomorrow, `false` if it isn't.
    public var isTomorrow: Bool {
        
        let calendar = Calendar.iso8601
        return calendar.isDateInTomorrow(self)
    }
    
    /// `true` if the date is a weekday, `false` if it isn't.
    public var isWeekday: Bool {
        
        let calendar = Calendar.iso8601
        return calendar.isDateInWeekend(self) == false
    }
    
    /// `true` if the date is a weekend, `false` if it isn't.
    public var isWeekend: Bool {
        
        let calendar = Calendar.iso8601
        return calendar.isDateInWeekend(self)
    }
    
    /// `true` if the date is the begining of the week, `false` if it isn't. Begining of week is Monday.
    public var isBeginingOfWeek: Bool {
        
        let calendar = Calendar.iso8601
        let components = calendar.dateComponents([.weekday], from: self)
        return components.weekday == 2 // Begining of week is Monday == 2
    }
    
    /// `true` if the date is the end of the week, `false` if it isn't. End of week is Sunday.
    public var isEndOfWeek: Bool {
        
        let calendar = Calendar.iso8601
        let components = calendar.dateComponents([.weekday], from: self)
        return components.weekday == 1 // End of week is Sunday == 1
    }
    
    /// `true` if the date is the begining of the month, `false` if it isn't.
    public var isBeginingOfMonth: Bool {
        
        let calendar = Calendar.iso8601
        let components = calendar.dateComponents([.day], from: self)
        return components.day == 1
    }
    
    /// `true` if the date is the end of the month, `false` if it isn't.
    /// NOTE: If a range can not be calculated to work out how many days are in the month, `false` will be returned.
    public var isEndOfMonth: Bool {
        
        let calendar = Calendar.iso8601
        let components = calendar.dateComponents([.day], from: self)
        guard let range = calendar.range(of: .day, in: .month, for: self) else {
            return false
        }
        return components.day == range.count
    }
    
    // MARK: - Duration
    
    /// Returns the day of the date
    public var day: Int? {
        
        let calendar = Calendar.iso8601
        let components = calendar.dateComponents([.day], from: self)
        return components.day
    }
    
    /// Returns the hour of the date
    public var hour: Int? {
        
        let calendar = Calendar.iso8601
        let components = calendar.dateComponents([.hour], from: self)
        return components.hour
    }
    
    /// Returns the minute of the date
    public var minute: Int? {
        
        let calendar = Calendar.iso8601
        let components = calendar.dateComponents([.minute], from: self)
        return components.minute
    }
    
    /// Returns the time of the date in hours
    public var timeInHours: TimeInterval? {
        
        let calendar = Calendar.iso8601
        let components = calendar.dateComponents([.minute, .hour], from: self)
        
        guard let minute = components.minute, let hour = components.hour else {
            return nil
        }
        
        return TimeInterval(hour) + (TimeInterval(minute) / 60)
    }
    
    /// Returns 1 minute in seconds `60`
    /// NOTE: This is just an aproximation, and should be used for quick, simple calculations ONLY!
    public static let minuteInSeconds: TimeInterval = 60
    
    /// Returns 1 hour in seconds `3600`
    /// NOTE: This is just an aproximation, and should be used for quick, simple calculations ONLY!
    public static let hourInSeconds: TimeInterval = minuteInSeconds * 60
    
    /// Returns 1 day in seconds `86400`
    /// NOTE: This is just an aproximation, and should be used for quick, simple calculations ONLY!
    public static let dayInSeconds: TimeInterval = hourInSeconds * 24
    
    /// Returns 1 week in seconds `604800`
    /// NOTE: This is just an aproximation, and should be used for quick, simple calculations ONLY!
    public static let weekInSeconds: TimeInterval = dayInSeconds * 7
    
    /**
    Returns the number of days between two dates
     
    - parameter fromDate:    The first date to count days from
    - parameter toDate:      The second date to count days to
     
    - returns: The number of days beteen `fromDate` and `toDate`
    */
    public static func daysBetween(_ fromDate: Date, to toDate: Date) -> Int? {
        
        let calendar = Calendar.iso8601
        
        let dateTo = calendar.startOfDay(for: toDate)
        let dateFrom = calendar.startOfDay(for: fromDate)
        
        let components = calendar.dateComponents([.day], from: dateFrom, to: dateTo)
        return components.day
    }
    
    /// Returns the number of days left in the current week assuming Monday is the start of the week and inclusive of today
    public var daysRemainingInWeek: Int? {
        
        let calendar = Calendar.iso8601
        let components = calendar.dateComponents([.weekday], from: self)
        guard var weekdayOfDate = components.weekday else {
            return nil
        }
        // To make Monday == 1
        weekdayOfDate -= 1
        if weekdayOfDate < 1 {
            weekdayOfDate = 7 + weekdayOfDate
        }
        return (7 - weekdayOfDate) + 1
    }
    
    /// Returns the number of days in the current month
    /// NOTE: If a range can not be calculated to work out how many days are in the month, `NSNotFound` will be returned.
    public var daysInMonth: Int {
        
        let calendar = Calendar.iso8601
        guard let range = calendar.range(of: .day, in: .month, for: self) else {
            return NSNotFound
        }
        return range.count
    }
    
    /// Returns the number of days left in the month, inclusive of today
    public var daysRemainingInMonth: Int? {
        
        let calendar = Calendar.iso8601
        let components = calendar.dateComponents([.day], from: self)
        
        guard let day = components.day else {
            return nil
        }
        
        return (daysInMonth - day)
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
    public func compare(_ date: Date, option: DateCompareType, shouldStripTime: Bool = true) -> Bool {
        
        var compare: ComparisonResult = .orderedSame
        if shouldStripTime == true {
            
            let strippedDate: Date
            if let stripTimeDate = stripTime {
                strippedDate = stripTimeDate
            } else {
                strippedDate = self
            }
            
            let strippedCompareDate: Date
            if let stripTimeDate = date.stripTime {
                strippedCompareDate = stripTimeDate
            } else {
                strippedCompareDate = date
            }
            
            compare = strippedDate.compare(strippedCompareDate)
            
        } else {
            compare = self.compare(date)
        }
        
        if compare == .orderedAscending {
            
            if option == .before || option == .beforeOrEqualTo {
                return true
            }
            
        } else if compare == .orderedDescending {
            
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
    public func isBefore(_ date: Date) -> Bool {
        return compare(date, option: .before)
    }
    
    /**
    Helper method for the `After` date comparison type used in `compareToDate(date:option:striptime:)`. This with compare with the time stripped.
     
    - parameter date:        The date to compare against
     
    - returns: `true` if the comparison date is after date, `false` if not
    */
    public func isAfter(_ date: Date) -> Bool {
        return compare(date, option: .after)
    }
    
    // MARK: - Date Changers
    
    /// Creates a new object which is a copy of the current date but with time stripped out (set to midnight)
    public var stripTime: Date? {
        
        var calendar = Calendar.iso8601
        calendar.timeZone = TimeZone.current
        let components = calendar.dateComponents(([.day, .month, .year]), from: self)
        return calendar.date(from: components)
    }
    
    /// Creates a new object which is a copy of the current date but with a certain number of years, months, days, hours, minutes and/or seconds added to it.
    ///
    /// - Parameters:
    ///   - years: The number of years to add, or `0` by default
    ///   - months: The number of months to add, or `0` by default
    ///   - days: The number of days to add, or `0` by default
    ///   - hours: The number of hours to add, or `0` by default
    ///   - minutes: The number of minutes to add, or `0` by default
    ///   - seconds: The number of seconds to add, or `0` by default
    ///   - timeZone: The time zone that should be set to the calendar when creating the new date.
    /// - Returns: A copy of the current date with the number of years, months, days, hours, minutes and/or seconds added to it.
    public func dateByAdding(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0, with timeZone: TimeZone? = nil) -> Date? {
        
        if years == 0 && months == 0 && days == 0 && hours == 0 && minutes == 0 {
            return self
        }
        
        var components = DateComponents()
        components.year = years
        components.month = months
        components.day = days
        components.hour = hours
        components.minute = minutes
        components.second = seconds
        
        var calendar = Calendar.iso8601
        if let timeZone = timeZone {
            calendar.timeZone = timeZone
        }
        return calendar.date(byAdding: components, to: self, wrappingComponents: false)
    }
    
    /// Returns a date of the current weeks from a weekday. Valid input numbers are `0` to `6`, and the time will always be midnight UTC.
    ///
    /// - Parameter day: The day of the week, starting at `0` and ending at `6`.
    /// - Returns: The date corisponding to the weekday for the current dates week.
    func weekdayInCurrentWeek(day: Int) -> Date? {
        
        var calendar = Calendar.iso8601
        calendar.timeZone = TimeZone.current
        let omponents = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: self)
        
        guard
            let beginningOfWeek = calendar.date(from: omponents),
            let nextDate = calendar.date(byAdding: .day, value: day, to: beginningOfWeek) else {
                return nil
        }
        
        return nextDate
    }
    
    /// Returns a date with the time at the start of the day, using the `current` time zone.
    public var dateAtStartOfDay: Date {
        
        var calendar = Calendar.iso8601
        calendar.timeZone = TimeZone.current
        return calendar.startOfDay(for: self)
    }
    
    /// Returns a date with the time at the end of the day, using the `current` time zone.
    /// NOTE: This will return `nil` if the calculation of date components returns `nil` in `dateByAdding(_:)`.
    public var dateAtEndOfDay: Date? {
        
        let timeZone = TimeZone.current
        return dateAtStartOfDay.dateByAdding(days: 1, seconds: -1, with: timeZone)
    }
    
    /// Returns a date with the date-time at the begining of the day of the current week, using the `current` time zone.
    /// NOTE: This will return `nil` if the calculation of date components returns `nil` in `weekdayInCurrentWeek(_:)`.
    public var dateAtStartOfWeek: Date? {
        return weekdayInCurrentWeek(day: 0)
    }
    
    /// Returns a date with the date-time at the end of the day of the current week, using the `current` time zone.
    /// NOTE: This will return `nil` if the calculation of date components returns `nil` in `weekdayInCurrentWeek(_:)`.
    public var dateAtEndOfWeek: Date? {
        
        guard let date = weekdayInCurrentWeek(day: 7) else {
            return nil
        }
        
        return date - 1
    }
    
    /// Returns a date with the date-time at the begining of the day of the current month, using the `current` time zone.
    /// NOTE: This will return `nil` if the calculation of date components returns `nil` in `weekdayInCurrentWeek(_:)`.
    public var dateAtStartOfMonth: Date? {
        
        let calendar = Calendar.iso8601
        var components = calendar.dateComponents(in: TimeZone.current, from: self)
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.day = 1
        
        return components.date
    }
    
    /// Returns a date with the date-time at the end of the day of the current month, using the `current` time zone.
    /// NOTE: This will return `nil` if the calculation of date components returns `nil` in `weekdayInCurrentWeek(_:)`.
    public var dateAtEndOfMonth: Date? {
        
        let calendar = Calendar.iso8601
        var components = calendar.dateComponents(in: TimeZone.current, from: self)
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        guard daysInMonth != NSNotFound else {
            return nil
        }
        components.day = daysInMonth
        
        return components.date
    }
    
    /// Returns a date with the date-time at the begining of the day of the current year, using the `current` time zone.
    /// NOTE: This will return `nil` if the calculation of date components returns `nil` in `weekdayInCurrentWeek(_:)`.
    public var dateAtStartOfYear: Date? {
        
        let calendar = Calendar.iso8601
        var components = calendar.dateComponents(in: TimeZone.current, from: self)
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.month = 1
        components.day = 1
        
        return components.date
    }
    
    /// Returns a date with the date-time at the end of the day of the current year, using the `current` time zone.
    /// NOTE: This will return `nil` if the calculation of date components returns `nil` in `weekdayInCurrentWeek(_:)`.
    public var dateAtEndOfYear: Date? {
        
        let calendar = Calendar.iso8601
        var components = calendar.dateComponents(in: TimeZone.current, from: self)
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.month = 12
        components.day = 31
        
        return components.date
    }
    
    // MARK: - Date Strings
    
    /// A helper method for getting a formatted string of the date and time in `short`
    public var dateTimeShortString: String {
        return  DateFormatter.localizedString(from: self, dateStyle: .short, timeStyle: .short)
    }
    
    /// A helper method for getting a formatted string of the date in `short`
    public var dateShortString: String {
        return  DateFormatter.localizedString(from: self, dateStyle: .short, timeStyle: .none)
    }
    
    /// A helper method for getting a formatted string of the date and time in `short`
    public var dateTimeMediumString: String {
        return  DateFormatter.localizedString(from: self, dateStyle: .medium, timeStyle: .short)
    }
    
    /// A helper method for getting a formatted string of the date in `short`
    public var dateMediumString: String {
        return  DateFormatter.localizedString(from: self, dateStyle: .medium, timeStyle: .none)
    }
    
    /// A helper method for getting a formatted string of the date in `full`
    public var dateFullString: String {
        return  DateFormatter.localizedString(from: self, dateStyle: .full, timeStyle: .none)
    }
    
    /// A helper method for getting a formatted string of the time in `short`
    public var timeShortString: String {
        return  DateFormatter.localizedString(from: self, dateStyle: .none, timeStyle: .short)
    }
    
    /// A helpter method for getting a formatted string of the date in the FUS set format.
    public var fusDateString: String {
        return dateString(fromFormat: "yyyy'-'MM'-'dd")
    }
    
    /// A helpter method for getting a formatted string of the date and time in the FUS set format.
    public var fusDateTimeString: String {
        
        let locale = Locale(identifier: "en_US_POSIX")
        return dateString(fromFormat: "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSSSSS'Z'", locale: locale)
    }
    
    /// A helper method for getting am ISO8601 formatted string from the current date
    public var iso8601String: String {
        
        if #available(iOSApplicationExtension 10.0, watchOSApplicationExtension 3.0, tvOSApplicationExtension 10.0, OSXApplicationExtension 10.12, *) {
            
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.timeZone = TimeZone.utc
            return dateFormatter.string(from: self)
            
        } else {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
            dateFormatter.timeZone = TimeZone.utc
            dateFormatter.locale = Locale.autoupdatingCurrent
            return dateFormatter.string(from: self)
        }
    }
    
    /**
    Takes the format of a date and returns a formatted string of the date.
     
    - parameter format: The format of the date string to return.
    - parameter locale: The locale to set to the date formatter (optional).
     
    - returns: The formatted date string.
    */
    public func dateString(fromFormat format: String, locale: Locale? = nil) -> String {
        
        let formatter = DateFormatter()
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
