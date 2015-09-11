//
//  NSCalendarExtensions.swift
//  FrostKit
//
//  Created by James Barrow on 01/10/2014.
//  Copyright (c) 2014-2015 James Barrow - Frostlight Solutions. All rights reserved.
//

import Foundation

///
/// Extention functions for NSCalendar
///
extension NSCalendar {
    
    /**
    A helper method to get the gregorian calendar.
    
    - returns: A gregorian calendar object.
    */
    public class func gregorianCalendar() -> NSCalendar {
        return NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    }
    
}
