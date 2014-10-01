//
//  NSDateExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright (c) 2014 Frostlight Solutions. All rights reserved.
//

import Foundation

extension NSDate {
    
    private func dateIsEqual(date: NSDate) -> Bool {
        let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        let dateComponents = calendar.components((NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitYear), fromDate: date)
        let components = calendar.components((NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitYear), fromDate: self)
        
        return components.day == dateComponents.day && components.month == dateComponents.month && components.year == dateComponents.year
    }
    
    public var isToday: Bool {
        return self.dateIsEqual(NSDate.date())
    }
    
    public var isYesterday: Bool {
        return self.dateIsEqual(NSDate(timeIntervalSinceNow: -86400)) // -24 hours
    }
    
    public var isTomorrow: Bool {
        return self.dateIsEqual(NSDate(timeIntervalSinceNow: 86400)) // 24 hours
    }
}
