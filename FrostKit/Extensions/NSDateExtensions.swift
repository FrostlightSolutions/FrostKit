//
//  NSDateExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright (c) 2014 Frostlight Solutions. All rights reserved.
//

import Foundation

extension NSDate {
    
    public var isToday: Bool {
        
        let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
            let today = calendar.components((NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitYear), fromDate: NSDate.date())
            let components = calendar.components((NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitYear), fromDate: self)
            
            return components.day == today.day && components.month == today.month && components.year == today.year
    }
    
    public var isYesterday: Bool {
        
        let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
            let today = calendar.components((NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitYear), fromDate: NSDate.date())
            let components = calendar.components((NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitYear), fromDate: self)
            
            var day = today.day - 1
            var month = today.month
            var year = today.year
            
            if day < 1 {
                
                month -= 1
                if month < 0 {
                    
                    month = 12
                    year -= 1
                }
                
                let lastMonthsComponents = NSDateComponents()
                lastMonthsComponents.month = month
                lastMonthsComponents.year = year
                
                if let lastMonthsDate = calendar.dateFromComponents(lastMonthsComponents) {
                    
                    let maxDaysRange = calendar.rangeOfUnit(.CalendarUnitDay, inUnit: .CalendarUnitMonth, forDate: lastMonthsDate)
                    day = maxDaysRange.length
                } else {
                    return false
                }
            }
            
            return components.day == day && components.month == month && components.year == year
    }
    
    public var isTomorrow: Bool {
        
        let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
            let today = calendar.components((NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitYear), fromDate: NSDate.date())
            let components = calendar.components((NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitYear), fromDate: self)
            
            var day = today.day + 1
            var month = today.month
            var year = today.year
            
            let maxDaysRange = calendar.rangeOfUnit(.CalendarUnitDay, inUnit: .CalendarUnitMonth, forDate: self)
            
            if day > maxDaysRange.length {
                
                day = 1
                month++
                
                if month > 12 {
                    
                    month = 1
                    year++
                }
            }
            
            return components.day == day && components.month == month && components.year == year
    }
}
