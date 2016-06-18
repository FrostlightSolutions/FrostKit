//
//  CalendarExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright © 2014-Current James Barrow - Frostlight Solutions. All rights reserved.
//

import Foundation

///
/// Extention functions for NSCalendar
///
extension NSCalendar {
    
    /**
    A helper method to get the iso8601 calendar.
    
    - returns: A iso8601 calendar object.
    */
    public class func iso8601Calendar() -> NSCalendar {
        return NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)!
    }
    
}
