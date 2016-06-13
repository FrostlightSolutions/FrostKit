//
//  CalendarExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright (c) 2014-2015 James Barrow - Frostlight Solutions. All rights reserved.
//

import Foundation

///
/// Extention functions for NSCalendar
///
extension Calendar {
    
    /**
    A helper method to get the iso8601 calendar.
    
    - returns: A iso8601 calendar object.
    */
    public class func iso8601Calendar() -> Calendar {
        return Calendar(calendarIdentifier: Calendar.Identifier.ISO8601)!
    }
    
}
